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

    def initialize(submission_path, assignment)
      super(submission_path, assignment)
      @timeout = 50
      @spec_file_path = assignment.assignment_spec_file
      raise NoSuchSpecError, 'Specs could not be found' unless File.readable? @spec_file_path
    end

    def grade(weighted=false)
      run_in_thread(runner_block)
      # run_in_subprocess(runner_block)
    end
    
    def compute_points (file_path)
      errs = StringIO.new('', 'w')
      output = StringIO.new('', 'w')
      points_max = 0
      points = 0
      RSpec.configure do |config|
        config.color = true
        config.tty = true
        config.formatter = 'documentation'
        config.formatter = 'RSpec::Core::Formatters::JsonPointsFormatter'
        config.output_stream = File.open('rspec_output.txt', 'wb')
        # getting rid of deprecation warnings
        config.expect_with(:rspec) { |cc| cc.syntax = [:should, :expect] }
        config.deprecation_stream = File.open('deprecations.txt', 'w')
      end
      RSpec::Core::Runner.run([file_path], errs, output)
      formatter = RSpec.configuration.formatters.select {|formatter| formatter.is_a? RSpec::Core::Formatters::JsonPointsFormatter}.first
      output_hash = formatter.output_hash
      output_hash[:examples].each do |example|
        points_max += example[:points]
        points += example[:points] if example[:status] == 'passed'
      end
      return points, points_max, [output.string, errs.string].join("\n")
    end

    def runner_block
      begin
        # raise "#{@submission_path}"
        Graders.load_student_files(@submission_path)
        RSpec.reset
        @raw_score, @raw_max, @comments = compute_points(@spec_file_path)
      rescue Exception => e
        puts 'When does this happen?'
        raise e
      end
      @output_hash = {raw_score: raw_score, raw_max: raw_max, comments: comments}
    end
  end
end