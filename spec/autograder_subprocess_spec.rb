# require 'spec_helper'

# describe AutoGraderSubprocess do

#   it "should be able to handle rspec output" do
#     file = File.open("spec/fixtures/rspec_output.txt", "rb")
#     str = file.read
#     file.close
#     lambda{ AutoGraderSubprocess.parse_grade(str) }.should_not raise_error
#   end

#   it "should be able to handle other junk in the rspec output" do
#     file = File.open("spec/fixtures/rspec_output_plus_junk.txt", "rb")
#     str = file.read
#     file.close
#     lambda{ AutoGraderSubprocess.parse_grade(str) }.should_not raise_error
#   end

# end

require 'spec_helper'
require 'run_with_timeout'


describe "AutoGraderSubprocess" do

  class ASGBase
    include AutoGraderSubprocess

  end

  def rspec_comments_and_score(comments, score)
    return "Score out of 100: #{score}\n" +
     "---BEGIN rspec comments---\n#{'-'*80}\n#{comments}\n#{'-'*80}\n---END rspec comments---"
  end

  let(:asg_runner) {ASGBase.new}
  before :each do
    Tempfile.stub(:open).and_yield(double.as_null_object)
  end

  it 'If the output does not contain a score it should raise output parse error' do
     AutoGraderSubprocess.stub(:run_with_timeout).and_return ["Hello World","",0]
     lambda{asg_runner.run_autograder_subprocess("puts hello world", "./spec", "WeightedRSpecGrader")}.should raise_error(AutoGraderSubprocess::OutputParseError)
  end

  it "Should raise a timeout error if the specs timeout" do
    AutoGraderSubprocess.stub(:run_with_timeout) {raise Timeout::Error}
     lambda{asg_runner.run_autograder_subprocess("puts hello world", "./spec", "WeightedRSpecGrader")}.should raise_error(
      AutoGraderSubprocess::SubprocessError, "AutograderSubprocess error: Program timed out")

  end

  it "Should parse the output to find the score and comments" do
    feedback = rspec_comments_and_score("Good work student!", 100)
    AutoGraderSubprocess.stub(:run_with_timeout).and_return [feedback,"",0]
    score, comments = asg_runner.run_autograder_subprocess("puts hello world", "./spec", "WeightedRSpecGrader")

    score.should == 100.0
    comments.should == "Good work student!"
  end
end