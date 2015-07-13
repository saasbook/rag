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
    end



    #kreddit for a lot of this code comes from here: https://gist.github.com/activars/4467752
    #TODO: internal hack below seems brittle, try to refactor that.
    def compute_points (file_path)
      points_max = 0
      points = 0
      config = RSpec.configuration
      formatter = RSpec::Core::Formatters::JsonPointsFormatter.new(config.output_stream)
      # create reporter with json formatter
      reporter =  RSpec::Core::Reporter.new(config)
      config.instance_variable_set(:@reporter, reporter)
      # internal hack
      # api may not be stable, make sure lock down Rspec version
      loader = config.send(:formatter_loader)
      notifications = loader.send(:notifications_for, RSpec::Core::Formatters::JsonPointsFormatter)
      reporter.register_listener(formatter, *notifications)
      RSpec::Core::Runner.run([file_path])
      formatter.output_hash[:examples].each do |example|
        points_max += example[:points]
        points += example[:points] if status == 'passed'
      end
      return points_max, points
    end

    def runner_block
      errs = StringIO.new('', 'w')
      output = StringIO.new('', 'w')
      begin
        load_student_files(@submission_path)
        RSpec::Core::Runner.run([@spec_file_path, '-fdocumentation'], errs, output)
        RSpec.clear_examples
        @raw_max, @raw_score = compute_points(file_path)
      rescue Exception => e
        puts 'When does this happen?'
        raise e
      end
      {points_received: @raw_score, points_maximum: @raw_max, comments: output}
    end
  end
end