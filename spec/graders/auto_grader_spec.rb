require 'spec_helper'
include Graders
#FakeFS.activate!
describe AutoGrader do
  before(:all) do
    FakeWeb.register_uri(:get, 'http://fixture.net/assignment1_spec.txt', :body => IO.read('spec/fixtures/ruby_intro_part1_spec.rb'))
  end
  context 'initialization' do
    before(:each) do
      submission = ::XQueueSubmission.create_from_JSON(double, IO.read('spec/fixtures/x_queue_submission.json'))
      submission.write_to_location! 'submissions/'
      @submission_path = submission.files.values.first
      @assignment = Assignment::Xqueue.new(submission)
    end
    it 'can create an RspecGrader with proper values' do
      grader = AutoGrader.create @submission_path, @assignment
      expect(grader).to be_a_kind_of(RspecGrader)
      expect(grader.spec_file_path).to be == "#{ENV['base_folder']}assignment1-spec"
    end
  end

  context 'restricts running time of test suites' do
    before(:each) do
      FakeWeb.register_uri(:get, 'http://fixture.net/timeout_submission.rb', body: IO.read('spec/fixtures/timeout_submission.rb'))
      submission = ::XQueueSubmission.create_from_JSON(double, IO.read('spec/fixtures/x_queue_submission_timeout.json')).fetch_files!
      submission.write_to_location! 'submissions/'
      @submission_path = submission.files.values.first
      @assignment = Assignment::Xqueue.new(submission)
      @grader = AutoGrader.create @submission_path, @assignment
    end
    it 'should kill the thread and return score of 0 if tests timeout' do
      @grader.instance_eval('@timeout = 2')  # so that this test doesn't take forever.
      @grader.grade
      expect(@output_hash).to be_nil
    end
  end
end
#FakeFS.deactivate!