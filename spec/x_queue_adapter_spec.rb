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

    end

    it 'should create an assignment (correctly) from the grader_payload' do
      ::XQueue.any_instance.stub(:get_submission).and_return(::XQueueSubmission.parse_JSON(@x_queue_adapter.x_queue, IO.read('spec/fixtures/x_queue_submission.json')))
      submission, assignment = @x_queue_adapter.get_submission_and_assignment
      expect(submission).to be
      # make sure that it has the correct values
      expect(submission.files.values[0]).to be == "http://fixture.net/correct_submission.zip"
      expect(assignment.assignment_spec_uri).to be == "http://fixture.net/assignment1_spec.txt"
    end

    it 'should give nil,nil when submission is nil' do
      ::XQueue.any_instance.stub(:get_submission).and_return(nil)
      _, assignment = @x_queue_adapter.get_submission_and_assignment
      expect(assignment).to_not be
    end

    it 'should submit response with correct argument values' do
      # submission, assignment = @x_queue_adapter.get_submission_and_assignment
      ::XQueueSubmission.any_instance.stub(:post_back)
      @x_queue_adapter.stub(:submit_response).with(an_instance_of(::XQueueSubmission))
    end

    # it 'should run without crashing' do
    #   @x_queue_adapter.stub(:get_submission_and_assignment).and_return(@x_queue_adapter.get_submission_and_assignment)
    #   @x_queue_adapter.stub(:submit_response)
    #   @x_queue_adapter.run
    # end

    it 'should run without crashing when submission and assignment are nil' do
      @x_queue_adapter.stub(:get_submission_and_assignment).and_return([nil, nil])
      @x_queue_adapter.stub(:submit_response)
      Xqueue.s(:sleep)
      @x_queue_adapter.run


    end
  end
end
