require 'auto_grader'
require 'graders/code_grader'
require 'ruby-debug'

describe CodeGrader do
  def fake_rspec_output(str)
    RspecRunner.any_instance.stub(:run_rspec).and_return(str)
  end
  it 'should give error when initializing with no specs' do
    lambda { CodeGrader.new('foo', {}) }.should raise_error NoSpecsGivenError
  end
  describe 'running valid specfile' do
    before :each do
      @g = CodeGrader.new('foo', :spec => 'spec/fixtures/correct_example.spec.rb')
    end
    it 'should give 100% on correct code' do
      fake_rspec_output '1 example, 0 failures'
      @g.grade!
      @g.normalized_score.should == 100
    end
    it 'should round up to 67% for 2 out of 3' do
      fake_rspec_output '3 examples, 1 failure'
      @g.grade!
      @g.normalized_score.should == 67
    end
    it 'should give 0 (not exception) for all failures' do
      fake_rspec_output '3 examples, 3 failures'
      @g.grade!
      @g.normalized_score.should be_zero
    end
  end
  describe 'running file with ruby syntax errors' do
  end
end
