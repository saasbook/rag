require 'spec_helper'

include Graders
FakeFS.activate!
describe RspecGrader do
  before(:all) do
    FakeWeb.register_uri(:get, 'http://fixture.net/assignment1_spec.txt', body: IO.read('spec/fixtures/ruby_intro_part1_spec.rb'))
    FakeWeb.register_uri(:get, 'http://fixture.net/correct_submission.rb', body: IO.read('spec/fixtures/ruby_intro_part1.rb'))
  end
  context 'should be able to grade a simple homework' do
    before(:each) do
      submission = ::XQueueSubmission.create_from_JSON(double, IO.read('spec/fixtures/x_queue_submission.json')).fetch_files!
      submission.write_to_location! 'submissions/'
      @submission_path = submission.files.values.first
      @assignment = Assignment::Xqueue.new(submission)
      @grader = AutoGrader.create(@submission_path, @assignment)
    end
    it 'gives points to a hw1 solution' do
      expect(RSpec.configuration.formatters.select {|formatter| formatter.is_a? RSpec::Core::Formatters::JsonPointsFormatter}.first).to be_nil
      b = @grader.grade
      b.should be_kind_of(Hash)
      expect(b[:raw_score]).to be == 30
      expect(RSpec.configuration.formatters.select {|formatter| formatter.is_a? RSpec::Core::Formatters::JsonPointsFormatter}.first).to be_nil
    end
  end
end
FakeFS.deactivate!
