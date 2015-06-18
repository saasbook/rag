require 'spec_helper'
include Adapter
describe Xqueue do
  context 'initialization from adapter factory with config file' do
    before(:each) do 
      @x_queue_adapter = create_adapter('./spec/fixtures/x_queue_config.yml')
    end

    it 'should not crash' do 
      expect(@x_queue_adapter).to be
    end

    it 'should have an x_queue corresponding to values from config file' do
      expect(@x_queue_adapter.x_queue.queue_name).to be == 'cs169x-development'
    end

  end
  context 'it can create an assignment from a submission and grade it' do 
    before(:each) do 
      @x_queue_adapter = create_adapter('./spec/fixtures/x_queue_config.yml')
      # @x_queue_adapter.stub_chain(:x_queue, :get_submission).
      #         and_return(::XQueueSubmission.parse_JSON(@x_queue_adapter.x_queue, IO.read('spec/fixtures/x_queue_submission.json')))
      ::XQueue.any_instance.stub(:get_submission).and_return(::XQueueSubmission.parse_JSON(@x_queue_adapter.x_queue, IO.read('spec/fixtures/x_queue_submission.json')))
    end

    it 'should create an assignment from the grader_payload' do 
      submission, assignment = @x_queue_adapter.get_submission_and_assignment
      expect(submission).to be
    end
  end
end