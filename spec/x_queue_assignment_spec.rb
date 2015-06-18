require 'spec_helper'
include Adapter
describe XQueueAssignment do
  context 'it can be initialized from a valid XQueueSubmission' do
    before(:each) do 
      x_q_double = double('XQueue')
      @x_q_submission = ::XQueueSubmission.parse_JSON(x_q_double, IO.read('spec/fixtures/x_queue_submission.json'))
    end
    it 'properly validates fields that need to exist when created' do
     expect(XQueueAssignment.new(@x_q_submission)).to be
    end
  end

  context 'when from invalid XQueueSubmission' do
    before(:each) do 
      x_q_double = double('XQueue')
      @x_q_submission = ::XQueueSubmission.parse_JSON(x_q_double, IO.read('spec/fixtures/invalid_x_queue_submission.json'))
    end

    it 'should validate presence of required fields' do 
      expect(XQueueAssignment.new(@x_q_submission).valid?).to be_false
    end
  end

  context 'can apply lateness to submissions based on assignment due dates' do 
    before(:each) do 
      x_q_double = double('XQueue')
      @x_q_submission = ::XQueueSubmission.parse_JSON(x_q_double, IO.read('spec/fixtures/x_queue_submission.json'))
      @x_q_assignment = XQueueAssignment.new(@x_q_submission)
      @x_q_submission.score, @x_q_submission.message = 1.0, 'good jerb student!!!!' #mock grading so that we can test penalization
    end

    it 'should not penalize for on time submissions' do 
      penalized_assignment = @x_q_assignment.apply_lateness(@x_q_submission)
      expect(penalized_assignment.score).to be == 1.0
    end

    it 'should penalize assignments that are in grace period' do
      @x_q_submission.stub(:submission_time).and_return(Time.parse('2015-01-02')) 
      penalized_assignment = @x_q_assignment.apply_lateness(@x_q_submission)
      expect(penalized_assignment.score).to be == 0.75
    end

    it 'should penalize assignments that are in late period' do 
      @x_q_submission.stub(:submission_time).and_return(Time.parse('2015-01-05')) 
      penalized_assignment = @x_q_assignment.apply_lateness(@x_q_submission)
      expect(penalized_assignment.score).to be == 0.50
    end

    it 'should not award points to assignments submitted past time' do 
      @x_q_submission.stub(:submission_time).and_return(Time.parse('2100-01-02')) 
      penalized_assignment = @x_q_assignment.apply_lateness(@x_q_submission)
      expect(penalized_assignment.score).to be == 0.0
    end
  end

end