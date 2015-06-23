require 'spec_helper'

describe Assignment::Xqueue do
  context 'it can be initialized from a valid XQueueSubmission' do
    before(:each) do
      puts 'hello world'
      double = double('XQueue')
      puts '1'
      @submission = ::XQueueSubmission.parse_JSON(double, IO.read('spec/fixtures/x_queue_submission.json'))
      puts '2'
    end
    it 'properly validates fields that need to exist when created' do
      puts '3'
      expect(Assignment::Xqueue.new(@submission)).to be
      puts '4'
    end
  end

  context 'when from invalid XQueueSubmission' do
    before(:each) do
      double = double('XQueue')
      @submission = ::XQueueSubmission.parse_JSON(double, IO.read('spec/fixtures/invalid_x_queue_submission.json'))
    end

    it 'should raise error when invalid' do
      expect{Assignment::Xqueue.new(@submission)}.to raise_error
    end
  end

  context 'can apply lateness to submissions based on assignment due dates' do
    before(:each) do
      double = double('XQueue')
      @submission = ::XQueueSubmission.parse_JSON(double, IO.read('spec/fixtures/x_queue_submission.json'))
      @assignment = Assignment::Xqueue.new(@submission)
      @submission.score = 1.0
      @submission.message = 'good jerb student!!!!' # mock grading so that we can test penalization
    end

    it 'should not penalize for on time submissions' do
      @assignment.apply_lateness! @submission
      expect(@submission.score).to be == 1.0
    end

    it 'should penalize assignments that are in grace period' do
      @submission.stub(:submission_time).and_return(Time.parse('2015-01-02'))
      @assignment.apply_lateness! @submission
      expect(@submission.score).to be == 0.75
    end

    it 'should penalize assignments that are in late period' do
      @submission.stub(:submission_time).and_return(Time.parse('2015-01-05'))
      @assignment.apply_lateness! @submission
      expect(@submission.score).to be == 0.50
    end

    it 'should not award points to assignments submitted past time' do
      @submission.stub(:submission_time).and_return(Time.parse('2100-01-02'))
      @assignment.apply_lateness! @submission
      expect(@submission.score).to be == 0.0
    end
  end
end
