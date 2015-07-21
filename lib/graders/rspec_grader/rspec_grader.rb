require 'rspec'
require 'json'
require_relative 'json_points_formatter'
module Graders
  class RspecGrader < AutoGrader
    class RspecGrader::NoSuchSpecError < StandardError ; end
    class RspecGrader::NoSpecsGivenError < StandardError ; end

    # The constructor is called from +AutoGrader.create+ so you shouldn't call
    # it directly.  The required and optional grading rules for
    # +RspecGrader+ are:
    # * +:spec+ - the full pathname to a specfile that will be run
    #   against the student's code.  The spec should <b>not</b> try to
    #   +require+ or +include+ the subject code file, but it can +require+
    #   or +include+ any other Ruby libraries needed for the specs to run.
    ERROR_HASH = {raw_score: 0, raw_max: 100, comments: 'There was a fatal error with your submission. It either timed out or caused an exception.'}
    def initialize(submission_path, assignment)
      super(submission_path, assignment)
      @timeout = 50
      @spec_file_path = assignment.assignment_spec_file
      raise NoSuchSpecError, 'Specs could not be found' unless File.readable? @spec_file_path
      @load_student_files = true  # some graders don't load student files.
    end

    def grade
      response = run_in_subprocess(method(:runner_block))
      if response
        response
      else
        ERROR_HASH
      end
    end
    
    def compute_points (file_path)
      errs = StringIO.new('', 'w')
      output = StringIO.new('', 'w')
      points_max = 0
      points = 0
      RSpec.reset
      RSpec.configure do |config|
        config.formatter = 'documentation'
        config.formatter = 'RSpec::Core::Formatters::JsonPointsFormatter'
      end
      RSpec::Core::Runner.run([file_path], errs, output)
      formatter = RSpec.configuration.formatters.select {|formatter| formatter.is_a? RSpec::Core::Formatters::JsonPointsFormatter}.first
      output_hash = formatter.output_hash
      output_hash[:examples].each do |example|
        points_max += example[:points]
        points += example[:points] if example[:status] == 'passed'
      end
       {raw_score: points, raw_max: points_max, comments: [output.string, errs.string].join("\n")}
    end

    def runner_block
      Graders.load_student_files(@submission_path) if @load_student_files
      compute_points(@spec_file_path)
    end
  end
end