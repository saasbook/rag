require 'spec_helper'

describe Adapter::Xqueue do
  before(:all) do
    FakeWeb.register_uri(:get, 'http://fixture.net/assignment1_spec.txt', :body => IO.read('spec/fixtures/ruby_intro_part1.rb'))
  end
  context 'initialization from adapter factory with config file' do
    before(:each) do
      require 'adapter'
      @x_queue_adapter = Adapter.load('./spec/fixtures/x_queue_config.yml')
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
      puts 'n'
      @x_queue_adapter = Adapter.load('./spec/fixtures/x_queue_config.yml')
      puts 'a'
      ::XQueue.any_instance.stub(:get_submission).and_return(::XQueueSubmission.create_from_JSON(@x_queue_adapter.x_queue, IO.read('spec/fixtures/x_queue_submission.json')))
      puts 'b'
    end

    it 'should create an assignment (correctly) from the grader_payload' do
      submission = @x_queue_adapter.next_submission_with_assignment
      assignment = submission.assignment
      expect(submission).to be
      # make sure that it has the correct values
      expect(submission.files.values[0]).to be == "http://fixture.net/correct_submission.zip"
      #expect(assignment.assignment_spec_uri).to be == "http://fixture.net/assignment1_spec.txt"
    end

    it 'should pass assignment and submission to the autograder' do
      pending 'run in a seperate thread to avoid infinite loop'
    end
  end

  context 'when there is no submission in queue' do
    before(:each) do
      @x_queue_adapter = Adapter.load('./spec/fixtures/x_queue_config.yml')
      ::XQueue.any_instance.stub(:get_submission).and_return(nil)
    end

    it 'it should not create an assignment' do
      submission = @x_queue_adapter.next_submission_with_assignment
      expect(submission).to_not be
    end

    it 'it should sleep when' do
      pending 'run in seperate thread to avoid infinite loop'
      # @x_queue_adapter.stub(:next_submission_and_assignment).and_return([nil, nil])
      # @x_queue_adapter.stub(:submit_response)
      # Xqueue.s(:sleep)
      # @x_queue_adapter.run
    end
  end
end
