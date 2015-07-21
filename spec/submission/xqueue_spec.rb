require 'spec_helper'

describe Submission::Xqueue do
  before(:all) do
    FakeWeb.register_uri(:get, 'http://fixture.net/assignment1_spec.txt', :body => IO.read('spec/fixtures/ruby_intro_part1_spec.rb'))
  end
  context 'initialization from adapter factory with config file' do
    before(:each) do
      require 'adapter'
      @x_queue_adapter = Submission.load('./spec/fixtures/x_queue_config.yml')
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
      @x_queue_adapter = Submission.load('./spec/fixtures/x_queue_config.yml')
      ::XQueue.any_instance.stub(:get_submission).and_return(::XQueueSubmission.create_from_JSON(@x_queue_adapter.x_queue, IO.read('spec/fixtures/x_queue_submission.json')))
    end

    it 'should create an assignment (correctly) from the grader_payload' do
      submission = @x_queue_adapter.next_submission_with_assignment
      assignment = submission.assignment
      expect(submission).to be
      expect(submission.files.values[0]).to include("submissions/abc123")
    end

    it 'should pass assignment and submission to the autograder' do
      pending 'run in a separate thread to avoid infinite loop'
      expect(true).to be_false
    end
  end

  context 'when there is no submission in queue' do
    before(:each) do
      @x_queue_adapter = Submission.load('./spec/fixtures/x_queue_config.yml')
      ::XQueue.any_instance.stub(:get_submission).and_return(nil)
    end

    it 'it should not create an assignment' do
      submission = @x_queue_adapter.next_submission_with_assignment
      expect(submission).to_not be
    end

    it 'it should sleep when' do
      pending 'run in seperate thread to avoid infinite loop'
      expect(true).to be_false
    end
  end
end
