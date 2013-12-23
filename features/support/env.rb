# Load code needed for Cuke scenarios
$APP = File.expand_path('.')
require File.join($APP, 'lib/auto_grader.rb')
require File.join($APP, 'lib/grader.rb')
# Use Rspec's expectations
require 'rspec/expectations'
require 'cucumber/rspec/doubles'

After do
  [@codefile, @specfile].each { |file| File.unlink(file) if (file && File.readable?(file)) }
end

