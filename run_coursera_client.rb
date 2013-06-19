#!/usr/bin/env ruby

require './lib/coursera_client.rb'

# First argument is optional, name of the configuration profile

CourseraClient.new(ARGV[0]).run
