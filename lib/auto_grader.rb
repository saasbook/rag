require 'tempfile'
require_relative 'rag_logger'

module Graders
  def self.join_student_and_spec_files(student_file_path, spec_file_path)
    raise "#{student_file_path} is not a directory. Student submission could not be loaded" unless Dir.exist? student_file_path
    joined_files_s = Dir[File.join(student_file_path, '**/*.rb')].map do  |file_name|
       IO.read(file_name)
    end.join("\n") + "\n" + IO.read(spec_file_path)
    Tempfile.open('spec_file') {|f| f.write joined_files_s; f}.path
  end
  class AutoGrader
    include RagLogger
    class AutoGrader::NoSuchGraderError < StandardError ; end

    # ==== Attributes
    # identifier of question being graded
    attr_accessor :assignment_id
    #  the maximum allowed duration that a test suite can run on a submission.
    attr_reader :timeout
    #student submission code path
    attr_reader :submission_path
    #assignment spec file path
    attr_reader :spec_file_path
    # Create a new autograder object, which will grade a student's submission
    # given the submission text, a grading strategy, and grading rules to be
    # used by that strategy.
    # * +assignment_id+ - string identifier for question being graded
    # * +grader+ - grading strategy to use.  Currently only +:rspec_grader+ is
    #   valid.  Raises +AutoGrader::NoSuchGraderError+ if nonexistent strategy
    #   specified.
    # * +submitted_answer+ - a string containing the student's submitted answer,
    #   such as code.
    # * +grading_rules+ - a hash containing the grading options supported by the
    #   chosen grading strategy.  See each strategy's class for what options are
    #   expected or required by that strategy.
    # * +normalize+ - if given, normalize score to this maximum; default 100
    require 'timeout'
    require_relative 'graders/rspec_grader/rspec_grader.rb'
    require_relative 'graders/rspec_grader/heroku_rspec_grader.rb'
    require_relative 'graders/rspec_grader/hw5_grader.rb'
    require_relative 'graders/feature_grader/hw3_grader.rb'
    require_relative 'graders/feature_grader/hw4_grader.rb'



    def self.create(submission_path, assignment)
      begin
        Graders.const_get(assignment.autograder_type.strip).new(submission_path, assignment)
      rescue NameError
        raise AutoGrader::NoSuchGraderError, "Can't find grading strategy for #{assignment.autograder_type}"
      end
    end

    # Grade the given question using the specified grader, strategy, and
    # maximum score. Return a hash of {raw_score: fixnum, raw_max: fixnum, comments: string}
    def grade
    end

    protected

    # Takes a Proc object representing the grading behavior of the auto grader and runs it in a separate process.
    # If the subprocess takes longer than @timeout seconds, the function will kill the subprocess and return a score
    # of 0.
    def run_in_subprocess(grading_func)
      begin
        read, write = IO.pipe
        logger.debug('Start subprocess to run student code.')
        @pid = fork do
            read.close
            # $stdout.reopen('stdout_subprocess', 'w')  # Don't clutter the main terminal with subprocess information.  If you are wondering, RSpec writes its output to STDOUT
            # $stderr.reopen('err_subprocess', 'w')  # and you can't redirect it w/o redirecting all of STDOUT.

            begin
              output_hash = grading_func.call
            rescue => e
              output_hash = { raw_score: 0, raw_max: 1, comments: e }
            end

            write.puts JSON.generate output_hash
            write.close
        end
        Timeout.timeout(timeout) do
          Process.wait @pid
        end
        write.close
        subprocess_response = read.gets
        output_hash = HashWithIndifferentAccess.new(JSON.parse(subprocess_response)) unless subprocess_response.nil?
        read.close
      rescue Timeout::Error
        logger.info('Subprocess timed out killed and submission received 0 pts.')
        Process.kill 9, @pid # dunno what signal to put for this
        Process.detach @pid  # express disinterest in process so that OS hopefully takes care of zombie
      end
      output_hash
    end

    # Superclass method to be called by inherited autograders
    def initialize(submission_path, assignment)
      @submission_path = submission_path
      @timeout = 20
    end
  end
end
