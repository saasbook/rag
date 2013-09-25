require 'spec_helper'

describe "Run With Timeout" do
    it 'should return output, error, and thread status' do
      opts = {
          :timeout => 4,
          :cmd => %Q{./grade "spec/fixtures/ruby_intro_part1.rb" "spec/fixtures/ruby_intro_part1_spec.rb"}
      }
      stdout_text, stderr_text, exitstatus = run_with_timeout(opts[:cmd], opts[:timeout])
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
