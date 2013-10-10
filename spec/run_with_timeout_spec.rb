require 'spec_helper'

describe "Run With Timeout" do

  [1].each do |tick|
    [4].each do |timeout|
      [1,50,128].each do |buffer_size|
        it "should return output, error, and thread status with a timeout of #{timeout} and tick #{tick} and buffer_size #{buffer_size} " do
          run_test timeout, tick, buffer_size
        end
      end
    end
  end

  def run_test(timeout=4,tick=1,buffer_size=256)
    opts = {
        :timeout => timeout,
        :cmd => %Q{./grade "spec/fixtures/ruby_intro_part1.rb" "spec/fixtures/ruby_intro_part1_spec.rb"},
        :tick => 1,
        :buffer_size => buffer_size
    }
    stdout_text, stderr_text, exitstatus = run_with_timeout(opts[:cmd], opts[:timeout], opts[:tick], opts[:buffer_size])
    stdout_text.should start_with "Score out of 100: 0"
    match = stdout_text.match(/---BEGIN (?:cucumber|rspec|grader) comments---\n#{'-'*80}\n(.*)#{'-'*80}\n---END (?:cucumber|rspec|grader) comments---/m)
    if match.nil?
      puts stdout_text
    end
    match.should_not be_nil
    comments = match[1]
    comments.should start_with "\nRuby intro part 1"
    formatted = comments.split("\n").map do |line|
      line.gsub(/\(FAILED - \d+\)/, "(FAILED)")
    end.join("\n")
    formatted.should start_with "\nRuby intro part 1\n  #sum\n    should be defined (FAILED)"
    stderr_text.should eq ""
    exitstatus.should eq 0
  end
end
