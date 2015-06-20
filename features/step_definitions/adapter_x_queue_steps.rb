require 'tempfile'
require 'xqueue_ruby'


BASE_FOLDER = './support/'
def fake_files(file_uris)
  if file_uris.is_a? Enumerable 
    file_uris.each {|file_uri| FakeWeb.register_uri(:get, file_uri, :body => IO.read("#{BASE_FOLDER}#{file_uri}")) }
  else 
    FakeWeb.register_uri(:get, file_uri, :body => IO.read("#{BASE_FOLDER}#{file_uris}"))
  end
end
      
Given(/^an XQueue that has submission "(.*?)" in queue$/) do |submission|
  response_file = "#{BASE_FOLDER}#{submission}"
  FakeWeb.register_uri(:get, %r|https://xqueue.edx.org/xqueue/get_submission/|, 
            :body => response_file)
  submission = XQueueSubmission.new(double('XQueue'), IO.read(response_file)).files
  fake_files(submission.grader_payload['assignment_spec_uri'])
  XQueue.any_instance.stub(:authenticated?).and_return(true)
  XQueue.any_Instance.stub(:queue_length).and_return(1)
end
