require 'auto_grader'
require 'graders/code_grader'
require 'ruby-debug'

describe CodeGrader do
  it 'should give error when initializing with no specs' do
    lambda { CodeGrader.new('foo', {}) }.should raise_error NoSpecsGivenError
  end
  describe 'running valid specfile' do
    describe 'on 100% correct code' do
      before :each do
        CodeGrader.send :public, :run_specs
        input = IO.read('spec/fixtures/correct_example.rb')
        @grader = CodeGrader.new(input, :spec => "spec/fixtures/correct_example.spec.rb")
      end
      it 'should give 100%' do
        @grader.run_specs
        @grader.normalized_score.should == 100
      end
    end
  end
end
