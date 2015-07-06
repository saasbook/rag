require 'tempfile'
require 'xqueue_ruby'
require 'json'
require 'adapter'

BASE_FOLDER = 'features/support/'

class PutResultException < StandardError ; end

def fake_files(file_uris)
  puts 'hello world!'
  if file_uris.is_a? Enumerable 
    file_uris.each do |file_uri| 
      local_file = (file_uri.split'/')[-1]
      puts "register_uri for : #{file_uri}"
      FakeWeb.register_uri(:get, file_uri, :body => IO.read("#{BASE_FOLDER}#{local_file}"))
    end
  else 
    local_file = (file_uris.split'/')[-1]
    FakeWeb.register_uri(:get, file_uris, :body => IO.read("#{BASE_FOLDER}#{local_file}"))
  end
end

Given(/^an XQueue that has submission "(.*?)" in queue$/) do |submission|
  response_file = "#{BASE_FOLDER}#{submission}"
  FakeWeb.register_uri(:get, %r|https://xqueue.edx.org/xqueue/get_submission/|, body: response_file)
  JSON_string = JSON.parse(IO.read(response_file))['content']
  submission = XQueueSubmission.create_from_JSON(double('XQueue'), JSON_string)
  puts submission.files.values
  fake_files(submission.files.values)
  fake_files(submission.grader_payload['assignment_spec_uri'])
  XQueue.any_instance.stub(:authenticated?).and_return(true)
  XQueue.any_instance.stub(:queue_length).and_return(1)
  allow_any_instance_of(XQueue).to receive(:put_result) do |instance, header, score, correct, message| 
    @results = {header: header, score: score, correct: correct, message: message}
    raise PutResultException
  end
end

Given(/^has been setup with the config file "(.*?)"$/) do |file_name|
  @adapter = SubmissionAdapter::load("features/support/#{file_name}")
end

#Starts a thread with stubbed out put_result to make a exception
Then(/^I should receive a grade for my assignment$/) do
  expect do 
    Thread.abort_on_exception = true
    thread = Thread.new do 
      @adapter.run
    end
     # sleep(10.0) #5 seconds longest reasonable time for submission before test fails 
     # thread.kill
     thread.join
  end.to raise_error(PutResultException)
  expect(@results[:score]).to be == 0
  puts @results[:comments]
end
