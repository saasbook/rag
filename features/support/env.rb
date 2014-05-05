# Load code needed for Cuke scenarios
$APP = File.expand_path('.')
require File.join($APP, 'lib/auto_grader.rb')
# Use Rspec's expectations
require 'rspec/expectations'
require 'cucumber/rspec/doubles'

After do
  [@codefile, @specfile].each do |file|
    if file && File.readable?(file)
      begin
        File.unlink file
      rescue Errno::ETXTBSY, 'Text file busy - config/test_autograders.yml' => e
        puts e.inspect
      end
    end 
  end
end

