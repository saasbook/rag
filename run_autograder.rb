#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'
require_relative 'lib/rag_logger'
include RagLogger

at_exit do
  FileUtils.rm_rf('temp_repo') # make sure we always do this even if we exit abnormally
  @@logger.close # flush the log file by closing the log.
  puts 'at_exit hook called'
end

options = {}
OptionParser.new do |opts|
  options = opts
  opts.banner = "Usage: run_autograder.rb configfile.yml"
end.parse!

unless ARGV.count == 1
  puts options
  puts "ARGV #{ARGV}"
  exit 1
end
require_relative 'lib/adapter'
autograder = Submission.load(ARGV[0])
autograder.run

