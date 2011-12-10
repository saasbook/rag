require 'auto_grader'
require 'graders/code_grader'
require 'ruby-debug'

describe CodeGrader do
  def fake_rspec_output(str,errors='')
    RspecRunner.any_instance.stub(:run_rspec).and_return([str,errors])
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
  end
end
