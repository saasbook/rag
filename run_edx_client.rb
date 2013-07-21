#!/usr/bin/env ruby

require './lib/edx_client.rb'
require 'rspec'
# First argument is optional, name of the configuration profile
#puts ARGV[0]
EdXClient.new(ARGV[0]).run
