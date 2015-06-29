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
      super(submitted_answer, grading_rules)
      @code = submitted_answer  # this be a string
      @specfile = assignment.assignment_spec_file
      @raw_score = 0
      @raw_max = 0
      raise NoSpecsGivenError if @specfile.nil? || @specfile.empty?
      raise NoSuchSpecError, "Specfile #{@specfile} not found" unless File.readable?(@specfile)
    end

    def grade!(weighted=false)
      runner =  runner_block
      runner.run
      @comments = runner.output
      if weighted
        @raw_score = runner.passed
        @raw_max = runner.total
      else
        runner.output.each_line do |line|  # TODO: this not the best code fix this when possible
          if line =~ /\[(\d+) points?\]/
            points = $1.to_i
            @raw_max += points
            @raw_score += points unless line =~ /\(FAILED([^)])*\)/
          elsif line =~ /^Failures:/
            mode = :log_failures
            break
          end
        end
      end
    end

    def runner_block
      $SAFE = 3
      errs = StringIO.new('', 'w')
      output = StringIO.new('', 'w')
      Tempfile.open(['rspec', '.rb']) do |file|
        begin
          # don't put anything before student code, so line numbers are preserved
          file.write(@code)
          # sandbox the code with timeouts
          file.write(@@preamble)
          # the specs that go with this code
          file.write(@specs)
          file.flush
          RSpec::Core::Runner::run([file.path], errs, output)
        rescue Exception => e
          # if tmpfile name appears in err msg, replace with 'your_code.rb' to be friendly
          output.string << e.message.gsub(file.path, 'your_code.rb')
          @errors = true
        end
      end
      return [output.string, errs.string].join("\n")
    end
  end
end