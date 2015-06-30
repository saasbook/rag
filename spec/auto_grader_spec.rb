require 'spec_helper'

describe AutoGrader do
  context 'initialization' do 
    before(:each) do 
      @submission_path = 'grader_files/submission_abc/'
      @assignment = double('XQueueSubmission')
    end
    it 'can create the right subclass of AutoGrader' do 
      pending 'write this' 
      expect(true).to be_false
    end
  end
end
