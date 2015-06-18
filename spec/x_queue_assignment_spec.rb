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

  context 'will not be initialized from invalid XQueueSubmission' do
    before(:each) do 
      x_q_double = double('XQueue')
      @x_q_submission = ::XQueueSubmission.parse_JSON(x_q_double, IO.read('spec/fixtures/invalid_x_queue_submission.json'))
    end

    it 'should validate presence of required fields' do 
      expect(XQueueAssignment.new(@x_q_submission).valid?).to be_false
    end
  end
end