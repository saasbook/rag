require 'tempfile'
require 'xqueue_ruby'
require 'json'
require 'adapter'


BASE_FOLDER = 'features/support/'
def fake_files(file_uris)
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
  FakeWeb.register_uri(:get, %r|https://xqueue.edx.org/xqueue/get_submission/|, 
            :body => response_file)
  JSON_string = JSON.parse(IO.read(response_file))['content']
  submission = XQueueSubmission.parse_JSON(double('XQueue'), JSON_string)
  puts submission.files.values
  fake_files(submission.files.values)
  fake_files(submission.grader_payload['assignment_spec_uri'])
  XQueue.any_instance.stub(:authenticated?).and_return(true)
  XQueue.any_instance.stub(:queue_length).and_return(1)
  XQueue.any_instance.stub(:put_result) do |header, score, correct, message| 
    @results = {header: header, score: score, correct: correct, message: message}
    raise 'need to throw exception to stop infinite loop'
  end

end

Given(/^has been setup with the config file "(.*?)"$/) do |file_name|
  @adapter = Adapter::load("features/support/#{file_name}")
end

Then(/^I should recieve a grade for my assignment$/) do
  expect do 
    Thread.abort_on_exception = true
    thread = Thread.new do 
      @adapter.run
    end
    sleep(3.0)
    expect(@results).to be
    thread.kill
  end.to raise_error
  puts @results[:score]
  puts @results[:message]
end

