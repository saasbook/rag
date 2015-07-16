require 'timeout'

module Graders
  def self.load_student_files(file_path)
    raise "#{file_path} is not a directory. Student submission could not be loaded" unless Dir.exist? file_path
    Dir[File.join(file_path, '*.rb')].each do  |file_name|
      load file_name
    end
  end
  class AutoGrader
    class AutoGrader::NoSuchGraderError < StandardError ; end

    # ==== Attributes

    # textual feedback from the autograder on the student's answer
    attr_accessor :comments
    #  errors running the autograder, if any; else nil
    attr_accessor :errors
    # identifier of question being graded
    attr_accessor :assignment_id
    #  achieved raw score as reported by the underlying grader
    attr_reader :raw_score
    #  the maximum possible raw score as reported by the underlying grader
    attr_reader :raw_max
    attr_reader :normalized
    #  the maximum allowed duration that a test suite can run on a submission.
    attr_reader :timeout
    #student submission code path
    attr_reader :submission_path

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
    require_relative 'graders/rspec_grader/rspec_grader'
    require_relative 'graders/rspec_grader/heroku_rspec_grader'
    #TODO: FIGURE OUT HOW TO LOAD OTHER AUTOGRADERS IN SMART WAY. PROBABLY SHOULD BE DONE THROUGH EXTERNAL GEMS


    def self.create(submission_path, assignment)
      begin
        Graders.const_get(assignment.autograder_type.strip).new(submission_path, assignment)
      rescue NameError => e
        raise e
        # raise AutoGrader::NoSuchGraderError, "Can't find grading strategy for #{assignment.autograder_type}" for some reason this will always run
      end
    end

    def normalized_score(max=100)
      raw_max.zero? ? 0 : (max.to_f * raw_score/raw_max).ceil
    end


    # Grade the given question using the specified grader, strategy, and
    # maximum score. Default method does nothing and leaves a score of 0
    def grade
    end

    protected

    # This is broken. Global RSpec singleton means that grading func will mess up the rspec object.

    def run_in_thread(grading_func)
      begin
        thr = Thread.new {$SAFE = 3; grading_func}
        thr.join(@timeout)
      rescue SecurityError => err
        puts 'got security exception'
      end
      @output_hash
    end

    def run_in_subprocess(grading_func)
      begin
        read, write = IO.pipe
        subprocess = fork do
          # begin
          #   $SAFE = 3
            output_hash = grading_func
            write.puts JSON.generate output_hash
            File.open('subprocess.txt', 'w') { |file| file.puts "#{Time.now}"}
            write.close
            exit(0)
          # rescue StandardError => e
          #   File.open('subprocess.txt', 'w') { |file| file.puts "#{Time.now} #{'-' * 80}\n #{e.backtrace.join "\n"}"}
          # end
        end
        Timeout.timeout(@timeout) do
          puts "WAITING FOR THREAD REGULAR #{'-' * 80}"
          Process.wait subprocess
          puts "DONE WAITING FOR THREAD REGULAR #{'-' * 80}"
        end
        @output_hash = HashWithIndifferentAccess.new(JSON.parse(read.gets))
        write.close
      rescue Timeout::Error
        puts "WAITING FOR THREAD TIMEOUT #{'-' * 80}"
        Process.kill 9, subprocess # dunno what signal to put for this
        Process.wait subprocess  # avoid zombie
        puts "DONE WAITING FOR THREAD TIMEOUT #{'-' * 80}"
        output_hash = nil
      ensure
        puts 'ensure statement'
      end
      @output_hash
    end

    # Superclass method to be called by
    def initialize(submission_path, assignment)
      @submission_path = submission_path
      @timeout = 20
    end
  end
end
