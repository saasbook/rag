require 'rspec'
require 'custom_json_formatter'
require 'json'
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
      super(submission_path, grading_rules)
      @spec_file_path = assignment.assignment_spec_file.path
      @raw_score = 0
      @raw_max = 0
      raise NoSpecsGivenError if @specfile.nil? || @specfile.empty?
      raise NoSuchSpecError, "Specfile #{@specfile} not found" unless File.readable?(@specfile)
    end

    def grade(weighted=false)
      text_report, json_report = run_in_thread(runner_block)
      raise "#{json_report.keys}"
      @comments = text_report
      object_json = json_report["summary"]
      if object_json.nil? && object_json["example_count"].nil?
        raise "json is nil"
      end
      total = object_json["example_count"]
      failed = object_json["failure_count"]
      pending = object_json["pending_count"]
      passed = @total - @failed - @pending
      if weighted
        @raw_score = passed
        @raw_max = total

      else

        # runner.output.each_line do |line|  # TODO: this not the best code fix this when possible
        #   if line =~ /\[(\d+) points?\]/
        #     points = $1.to_i
        #     @raw_max += points
        #     @raw_score += points unless line =~ /\(FAILED([^)])*\)/
        #   elsif line =~ /^Failures:/
        #     mode = :log_failures
        #     break
        #   end
        # end
      end
      @raw_score = parse_JSON_report(json_report)
      return raw_score, text_report
    end

    def runner_block
      errs = StringIO.new('', 'w')
      output = StringIO.new('', 'w')
      _errs = StringIO.new('', 'w')
      output_JSON = StringIO.new('', 'w')
      begin
        load_student_files(@submission_path)
        RSpec::Core::Runner.run([@spec_file_path, '-fdocumentation'], errs, output)
        RSpec.reset
        RSpec::Core::Runner.run([@spec_file_path, '--format CustomJsonFormatter'], _errs, output_JSON)
      rescue Exception => e
        puts 'When does this happen?'
        raise e
      end
      return [output.string, errs.string].join("\n"), JSON.parse(outputJSON.string)
    end
  end
end