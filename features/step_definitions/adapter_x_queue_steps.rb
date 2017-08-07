require 'tempfile'
require 'xqueue_ruby'
require 'json'
require 'adapter'
require 'submission/xqueue'
require 'fakeweb'

BASE_FOLDER = 'features/support/'

class PutResultException < StandardError ; end

def fake_files(file_uris)
  if file_uris.is_a? Enumerable 
    file_uris.each do |file_uri| 
      local_file = (file_uri.split'/')[-1]
      # puts "register_uri for : #{file_uri}"
      FakeWeb.register_uri(:get, file_uri, :body => IO.read("#{BASE_FOLDER}#{local_file}"))
    end
  else 
    local_file = (file_uris.split'/')[-1]
    FakeWeb.register_uri(:get, file_uris, :body => IO.read("#{BASE_FOLDER}#{local_file}"))
  end
end

Given(/^(?:|I) set up a test that requires internet connection$/) do
  FakeWeb.allow_net_connect = true
end

Given(/^an XQueue that has submission "(.*?)" in queue$/) do |submission|
  response_file = "#{BASE_FOLDER}#{submission}"
  FakeWeb.register_uri(:get, %r|https://xqueue.edx.org/xqueue/get_submission/|, body: response_file)
  json_string = JSON.parse(IO.read(response_file))['content']

  # this constructs the incoming XQueueSubmission object that the live grader might receive
  submission = XQueueSubmission.create_from_JSON(double('XQueue'), json_string)
  # puts submission.files.values

  # this takes the specified student submitted files and simulates their availability over
  # the network with the actual files in the `features/support` directory
  fake_files(submission.files.values)

  # this takes the specified assignment specs and simulates their availability over
  # the network with the actual files in the `features/support` directory
  fake_files(submission.grader_payload['assignment_spec_uri']) if submission.grader_payload['assignment_spec_uri'].include? 'fakedownload'
  XQueue.any_instance.stub(:authenticated?).and_return(true)
  XQueue.any_instance.stub(:queue_length).and_return(1)

  # presumably this allows the final result to be added subsequently
  allow_any_instance_of(XQueue).to receive(:put_result) do |_instance, header, score, correct, message|
    @results = {header: header, score: score, correct: correct, message: message}
    raise PutResultException
  end
end

Given(/^has been setup with the config file "(.*?)"$/) do |file_name|
  # presumably this is the adapter.rb Submission?
  # and it looks like it sets up a Xqueue with the appropriate config
  # and this then starts the loop that will actually grade the submission?
  # or that's triggered by @adapter.run in the step below?
  @adapter = Submission.load("features/support/#{file_name}")
end

# Starts a thread with stubbed out put_result to make a exception
Then(/^I should receive a grade of "(.*?)" for my assignment$/) do |grade|
  # expect do
  #   Thread.abort_on_exception = true
  #   thread = Thread.new do
  #     @adapter.run
  #   end
  #    thread.join
  # end.to raise_error(PutResultException)
  begin
    @adapter.run
  rescue PutResultException
  end
  expect(@results[:score].round(1)).to be == grade.to_f
  expect(@results[:message]).not_to be_empty
  # puts "#{@results[:message]}"
end

And(/^results should include "(.*?)"$/) do |message|
  expect(@results[:message]).to include message
end

And(/^I've hacked the grader to have a short timeout$/) do
  class Graders::AutoGrader
    def timeout; 20; end
  end
end

Given(/^the submissions directory has been cleared$/) do
  `rm -rf submissions`
end