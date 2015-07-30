# Load code needed for Cuke scenarios
$APP = File.expand_path('.')
require File.join($APP, 'lib/auto_grader.rb')
# Use Rspec's expectations
require 'rspec/expectations'
require 'cucumber/rspec/doubles'
require 'fakeweb'

#FakeWeb.allow_net_connect = false

After do
  [@codefile, @specfile].each { |file| File.unlink(file) if (file && File.readable?(file)) }
  FileUtils.rm_rf('submissions')  # clear caching for each test. Works with or without
end

