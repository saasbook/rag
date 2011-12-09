class AutoGraderSpec

  describe 'initializing' do
    context 'with valid grader' do
      it 'should succeed' do
        AutoGrader.new('MultipleChoiceGrader', '', {}).should be_a_kind_of AutoGrader
      end
    end
  end
end
