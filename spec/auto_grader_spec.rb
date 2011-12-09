require 'auto_grader'
describe AutoGrader do
  describe 'initializing' do
    it 'should succeed with valid grader' do
      AutoGrader.new('MultipleChoiceGrader', 'b', {}).should be_a_kind_of AutoGrader
    end
    it 'should raise NoSuchGraderError with invalid grader' do
      lambda { AutoGrader.new 'Bad', 'b', {} }.should raise_error(AutoGrader::NoSuchGraderError)
    end
  end
  describe 'generic grading' do
    describe 'with an empty answer' do
      before :each do
        @grader = AutoGrader.new('MultipleChoiceGrader', '', {})
        @grader.grade!
      end
      it 'should return a score of 0.0' do
        @grader.normalized_score.should == 0.0
      end
      it 'should include a message' do
        @grader.comments.should_not be_empty
      end
    end
  end
end
