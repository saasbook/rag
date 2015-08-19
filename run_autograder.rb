#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'
options = {}
OptionParser.new do |opts|
  options = opts
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

unless ARGV.count == 1
  puts options
  puts "ARGV #{ARGV}"
  exit 1
end
require_relative 'lib/adapter'
autograder = Submission.load(ARGV[0])
autograder.run

at_exit do
  FileUtils.rm_rf('temp_repo') # make sure we always do this even if we exit abnormally
end