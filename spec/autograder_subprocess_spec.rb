require 'spec_helper'

describe AutoGraderSubprocess do

  it "should be able to handle rspec output" do
    file = File.open("spec/fixtures/rspec_output.txt", "rb")
    str = file.read
    file.close
    lambda{ AutoGraderSubprocess.parse_grade(str) }.should_not raise_error
  end

  it "should be able to handle other junk in the rspec output" do
    file = File.open("spec/fixtures/rspec_output_plus_junk.txt", "rb")
    str = file.read
    file.close
    lambda{ AutoGraderSubprocess.parse_grade(str) }.should_not raise_error
  end

end