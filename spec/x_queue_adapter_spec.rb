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
      # create_xqueue_hash works here correctly
      expect(@x_queue_adapter.x_queue.queue_name).to be == 'cs169x-development'
    end
  end

  context 'it can create an assignment from a submission and grade it' do
    before(:each) do
      @x_queue_adapter = create_adapter('./spec/fixtures/x_queue_config.yml')
      ::XQueue.any_instance.stub(:get_submission).and_return(::XQueueSubmission.parse_JSON(@x_queue_adapter.x_queue, IO.read('spec/fixtures/x_queue_submission.json')))
    end

    it 'should create an assignment (correctly) from the grader_payload' do
      submission, assignment = @x_queue_adapter.get_submission_and_assignment
      expect(submission).to be
      # make sure that it has the correct values
      expect(submission.files.values[0]).to be == "http://fixture.net/correct_submission.zip"
      expect(assignment.assignment_spec_uri).to be == "http://fixture.net/assignment1_spec.txt"
    end

    it 'should pass assignment and submission to the autograder' do 
      pending 'run in a seperate thread to avoid infinite loop'
    end
  end 

  context 'when there is no submission in queue' do
    before(:each) do
      @x_queue_adapter = create_adapter('./spec/fixtures/x_queue_config.yml')
      ::XQueue.any_instance.stub(:get_submission).and_return(nil)
    end

    it 'it should not create an assignment' do
      _, assignment = @x_queue_adapter.get_submission_and_assignment
      expect(assignment).to_not be
    end

    it 'it should sleep when' do
      pending 'run in seperate thread to avoid infinite loop'
      # @x_queue_adapter.stub(:get_submission_and_assignment).and_return([nil, nil])
      # @x_queue_adapter.stub(:submit_response)
      # Xqueue.s(:sleep)
      # @x_queue_adapter.run
    end

  end
end
