#!/usr/bin/env ruby

require './lib/edx_client.rb'
require 'rspec'
# First argument is optional, name of the configuration profile
#puts ARGV[0]
edx_client = EdXClient.new(ARGV[0])
puts "The queue name is #{edx_client.name}"
edx_client.run

