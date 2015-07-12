require 'spec_helper'
include Graders


describe AutoGrader do
  before(:all) do
    FakeWeb.register_uri(:get, 'http://fixture.net/assignment1_spec.txt', :body => IO.read('spec/fixtures/ruby_intro_part1.rb'))
  end
  context 'initialization' do
    before(:each) do
      submission = ::XQueueSubmission.create_from_JSON(double, IO.read('spec/fixtures/x_queue_submission.json'))
      submission.write_to_location! 'submissions/'
      @submission_path = submission.files.values.first
      @assignment = submission.assignment
    end
    it 'can create an RSpecGrader with proper values' do
      grader = AutoGrader.create @submission_path, @assignment
      expect(grader).to be_a_kind_of(RspecGrader)
    end
  end

  context 'restricts running time of test suites' do
    before(:each) do
      @submission_path = 'grader_files/submission_abc/'
      @assignment = double('XQueueSubmission')
    end
    it 'should kill the thread and return score of 0 if tests timeout' do
      pending 'write this'
      expect(true).to be_false
    end
    it 'should not kill threads before they timeout' do
      pending 'write this'
      expect(true).to be_false
    end
  end

 context 'is reliable' do
    before(:each) do
      @submission_path = 'grader_files/submission_abc/'
      @assignment = double('XQueueSubmission')
    end
    it 'should not crash on faulty student submitted code' do
      pending 'write this'
      expect(true).to be_false
    end
  end
  context 'protects against malicious code' do
    before(:each) do
      @submission_path = 'grader_files/submission_abc/'
      @assignment = double('XQueueSubmission')
    end
    it 'does not allow students to modify global variables' do
      pending 'write this'
      expect(true).to be_false
    end
    it 'does not allow students to modify variables of main thread' do
      pending 'write this'
      expect(true).to be_false
    end
    it 'does not allow students to modify RSpec' do
      pending 'write this'
      expect(true).to be_false
    end
  end

  context 'returns a score and commnents for basic Rspec homeworks do' do
    before(:each) do
      @submission_path = 'grader_files/submission_abc/'
      @assignment = double('XQueueSubmission')
    end
    it 'gives full points for good submission' do
      pending 'write this'
      expect(true).to be_false
    end
    it 'gives partial credit for partially correct solutions' do
      pending 'write this'
      expect(true).to be_false
    end
  end

  context 'grades heroku projects' do
    before(:each) do
      @submission_path = 'grader_files/submission_abc/'
      @assignment = double('XQueueSubmission')
    end
    it 'gives full points for good submission' do
      pending 'write this'
      expect(true).to be_false
    end
    it 'gives partial credit for partially correct solutions' do
      pending 'write this'
      expect(true).to be_false
    end
  end

  context 'grades rails applications' do
    before(:each) do
      @submission_path = 'grader_files/submission_abc/'
      @assignment = double('XQueueSubmission')
    end
    it 'gives full points for good submission' do
      pending 'write this'
      expect(true).to be_false
    end
    it 'gives partial credit for partially correct solutions' do
      pending 'write this'
      expect(true).to be_false
    end
  end
end
