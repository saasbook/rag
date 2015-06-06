class FeatureGrader < AutoGrader
  class Feature
    class TestFailedError < StandardError; end   # Internal error
    class IncorrectAnswer < StandardError; end   # Incorrect answer encountered

    SOURCE_DB = "db/test.sqlite3"

    module Regex
      BlankLine = /^$/
      FailingScenarios = /^Failing Scenarios:$/
      StepResult = /^(\d+) steps? \(.*?(\d+) passed.*\)/
    end

    attr_reader :if_pass, :target_pass, :feature, :score, :output, :desc, :weight

    attr_reader :grader

    # +Array+ of +ScenarioMatcher+s that should fail for this step,
    # or empty if it should pass in +cucumber+.
    attr_reader :failures

    # +Hash+ with
    # [+:failed+] _Array_<_String_> +cucumber+ scenarios that failed
    # [+:missing+] _Array_<_ScenarioMatcher_> +cucumber+ scenarios that weren't seen running
    # [+:steps+] [_Hash_] +:total+, +:passed+
    attr_reader :scenarios

    class << self

      # Compute the total +Score+ resulting from the given array
      # of +Feature+s.
      #
      # See +$config[:mt]+
      #
      def total(features=[])
        s = Score.new
        m = Mutex.new
        #threads = []
        features.each do |f|
          #t = Thread.new do
            begin
              result = f.run!
              m.synchronize { s += result }
            rescue TestFailedError, IncorrectAnswer
              m.synchronize { s += -result }
            end
          #end
          #t.join unless $config[:mt]
          #threads << t
        end
        #threads.each(&:join)

        # Dump output. TODO: better way to do this?
        features.each { |f| f.dump_output }

        return s
      end
    end

    # +feature+ is a +Hash+ containing
    # [+:FEATURE+] path to feature file
    # [+:pass+]    +boolean+ specifying whether the feature should pass or not
    # [+:if_pass+] additonal +Feature+s to run iff this one passes (recursive +Hash+ structure)
    # [+:failures+] +ScenarioMatcher+s that indicate which scenarios should fail
    #               for this step
    # [...]        and any other environment variables

    def initialize(grader, feature_={}, config={})
      feature = feature_.dup
      raise ArgumentError, "No 'FEATURE' specified in #{feature.inspect}" unless feature['FEATURE']

      @grader = grader
      @score = Score.new
      @config = config
      @output = []
      @desc = feature.delete("desc") # || 'None'
      @weight = feature.delete("weight").to_f || 1.0

      @if_pass = []
      if feature["if_pass"] and feature["if_pass"].is_a? Array
        @if_pass += feature.delete("if_pass").collect {|f| Feature.new(self, f, config)}
      end

      @target_pass = feature.has_key?("pass") ? feature.delete("pass") : true

      @failures = feature.delete("failures") || []
      @scenarios = {
        :failed  => [],
        :missing => []
      }

      @env = feature.envify  # whatever's left over
    end

    def log(*args)
      @output += [*args]
    end

    def dump_output
      self.grader.log(@output)
    end

    def run!
      log '-'*80

      h = @env.dup

      score = Score.new
      num_failed = 0
      passed = false
      lines = []

      h["FEATURE"] = File.join(@config[:temp].path, h["FEATURE"])

      $m_db.synchronize do
        h["TEST_DB"] = File.join(@config[:temp].path, "test_#{$i_db}.sqlite3")
        $i_db += 1
      end

      popen_opts = {
        #:unsetenv_others => true     # TODO why does this make cucumber not work?
      }

      #log "Cuking with #{h.inspect}"

      begin
        raise TestFailedError, "Nonexistent feature file #{h["FEATURE"]}" unless File.readable? h["FEATURE"]

        raise(TestFailedError, "Failed to find test db") unless File.readable? SOURCE_DB
        FileUtils.cp SOURCE_DB, h["TEST_DB"]
        Open3.popen3(h, $CUKE_RUNNER, popen_opts) do |stdin, stdout, stderr, wait_thr|
          #exit_status = wait_thr.value

          lines = stdout.readlines
          lines.each(&:chomp!)
          self.send :process_output, lines
        end

      ##
      # XXX Can only raise StandardError in these rescue clauses.
      # Any other subclass will give incorrect results ("undefined method `-@'").
      ##

      rescue TestFailedError => e
        log "test failed: #{e.inspect}"
        log e.backtrace
        raise StandardError, e.message

      rescue => e
        log "test failed: #{e.inspect}"#.red.bold
        log e.backtrace
        raise StandardError, "test failed to run because #{e.message}"

      ensure
        FileUtils.rm h["TEST_DB"] if File.exists? h["TEST_DB"]

      end

      if self.correct?
        #log "Test #{h.inspect} passed.".green

        if self.weight
          score += @weight
        else
          score.pass @weight
        end

        log "Test passed. (+#{score.max})"
        score += Feature.total(@if_pass)
      else
        #log "Test #{h.inspect} failed".red
        begin
          self.correct!
        rescue TestFailedError, IncorrectAnswer => e
          log e.message
        end
        log lines.collect {|l| "| #{l}"}
        score.fail @weight
        log "Test failed. (-#{score.max})"
      end

      return score
    end

    def correct?
      begin
        correct!
        return true
      rescue
        return false
      end
    end

    # This step is correct if:
    #   any +failures+ +?+ all +failures+ have failed +:+ it passed in cucumber
    def correct!

      if @scenarios[:missing].any?
        raise IncorrectAnswer, "Could not find required scenario(s): #{@scenarios[:missing].collect(&:desc).join(", ")}"
      end

      if @failures.any?
        unless @failures.all? {|matcher| @scenarios[:failed].any? {|s| matcher.match? s}}
          missing_failures = @failures.reject {|matcher| @scenarios[:failed].any? {|s| matcher.match? s}}
          missing_failures = missing_failures.collect{|f| " - #{f.to_s}"}.join("\n")
          mods = self.desc || "(None)"
          mods = " - #{mods}"
          raise IncorrectAnswer, [
            "The following required failures were not detected:", missing_failures,
            "with the following modifications:", mods
          ].join("\n")
        end
      else
        unless @scenarios[:failed].empty? or @scenarios[:steps][:total] != @scenarios[:steps][:passed]
          raise IncorrectAnswer, "Feature should have passed, but had the following failures:\n#{@scenarios[:failed].collect {|f| "  #{f}"}}"
        end
      end
      true
    end

  private
    # Parses and remembers relevant output from +cucumber+.
    # [+output+] +Array+ of stdout lines from +rake cucumber+, e.g. from +readlines+
    def process_output(output)
      raise ArgumentError unless output and output.is_a? Array

      begin # parse failing scenarios (between FailingScenarios and BlankLine)
        if i = output.find_index {|line| line =~ Regex::FailingScenarios}

          begin # check for required scenarios
            temp = output[0..i]
            @scenarios[:missing] = @failures
            temp.each do |line|
              if failure = @failures.detect {|f| f.present_on?(line)}
                @scenarios[:missing] -= [failure]
              end
            end
          end

          temp = output[i+1..-1]
          i = temp.find_index {|line| line =~ Regex::BlankLine}
          @scenarios[:failed] = temp.first(i)
        end
      rescue => e
        raise
      end

      begin # parse result counts
        result_lines = output.grep Regex::StepResult

        unless result_lines.count == 1
          log output
          raise TestFailedError, "invalid cucumber results" + output.join("\n")
        end
        num_steps, num_passed = result_lines.first.scan(Regex::StepResult).first
        @scenarios[:steps] = {:total => num_steps, :passed => num_passed}
      rescue => e
        raise
      end

    end

  end
end
