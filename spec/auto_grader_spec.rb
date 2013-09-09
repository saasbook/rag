require 'auto_grader'
describe AutoGrader do
  describe 'initializing with valid grader' do
    subject { AutoGrader.create('1-1', 'MultipleChoiceGrader', 'b', {}) }
    it { should be_a_kind_of AutoGrader }
    it 'should copy assignment_id' do ; subject.assignment_id.should == '1-1' ; end
  end
  it 'should raise NoSuchGraderError with invalid grader' do
    lambda { AutoGrader.create '1-1', 'Bad', 'b', {} }.
      should raise_error(AutoGrader::NoSuchGraderError)
  end
  describe 'generic grading' do
    describe 'with an empty answer' do
      before :each do
        @grader = AutoGrader.create('1-1', 'MultipleChoiceGrader', '', {})
        @grader.grade!
      end
      it 'should return a score of 0.0' do
        @grader.normalized_score.should == 0.0
      end
      it 'should include a message' do
        @grader.comments.should_not be_empty
      end
    end
    describe 'with wonky input', :shared => true do
      it 'should not choke' do
        pending "Code to test chokage with bad file inputs"
      end
    end
    describe 'with binary file' do ; it_should_behave_like 'with wonky input' ; end
    describe 'with non-7-bit ASCII' do ; it_should_behave_like  'with wonky input' ;  end
    describe 'with unicode' do ; it_should_behave_like 'with wonky input' ;  end
  end
end
