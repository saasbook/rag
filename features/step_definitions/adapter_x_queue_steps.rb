require 'tempfile'
require 'xqueue_ruby'
require 'json'
require 'adapter'

BASE_FOLDER = 'features/support/'
def fake_files(file_uris)
  if file_uris.is_a? Enumerable
    file_uris.each do |file_uri|
      file_uri = (file_uri.split '/')[-1]
      FakeWeb.register_uri(:get, file_uri, body: IO.read("#{BASE_FOLDER}#{file_uri}"))
    end
  else
    file_uris = (file_uris.split '/')[-1]
    FakeWeb.register_uri(:get, file_uris, body: IO.read("#{BASE_FOLDER}#{file_uris}"))
  end
end

Given(/^an XQueue that has submission "(.*?)" in queue$/) do |submission|
  response_file = "#{BASE_FOLDER}#{submission}"
  FakeWeb.register_uri(:get, %r|https://xqueue.edx.org/xqueue/get_submission/|, body: response_file)
  JSON_string = JSON.parse(IO.read(response_file))['content']
  submission = XQueueSubmission.parse_JSON(double('XQueue'), JSON_string)
  fake_files(submission.files.values)
  fake_files(submission.grader_payload['assignment_spec_uri'])
  XQueue.any_instance.stub(:authenticated?).and_return(true)
  XQueue.any_instance.stub(:queue_length).and_return(1)
end

Given(/^has been setup with the config file "(.*?)"$/) do |file_name|
  @adapter = Adapter.create_adapter("config/features/#{file_name}")
end

Then(/^I should receive a grade for my assignment$/) do
  expect()
end
