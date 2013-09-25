require 'spec_helper'

describe "Run With Timeout" do

  (1..2).each do |tick|
    (2..5).each do |timeout|
      it "should return output, error, and thread status with a timeout of #{timeout} and #{tick}" do
        run_test timeout,tick
      end
    end
  end

  def run_test(timeout=4,tick=1)
    opts = {
        :timeout => timeout,
        :cmd => %Q{./grade "spec/fixtures/ruby_intro_part1.rb" "spec/fixtures/ruby_intro_part1_spec.rb"},
        :tick => 1
    }
    stdout_text, stderr_text, exitstatus = run_with_timeout(opts[:cmd], opts[:timeout], opts[:tick])
    stdout_text.should start_with "Score out of 100: 0"
    comments = stdout_text.match(/---BEGIN (?:cucumber|rspec|grader) comments---\n#{'-'*80}\n(.*)#{'-'*80}\n---END (?:cucumber|rspec|grader) comments---/m)[1]
    comments.should start_with "\nRuby intro part 1"
    formatted = comments.split("\n").map do |line|
      line.gsub(/\(FAILED - \d+\)/, "(FAILED)")
    end.join("\n")
    formatted.should start_with "\nRuby intro part 1\n  #sum\n    should be defined (FAILED)"
    stderr_text.should eq ""
    exitstatus.should eq 0
  end
end
