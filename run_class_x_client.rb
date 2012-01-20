#!/usr/bin/env ruby

require 'yaml'
require './lib/class_x_client.rb'

unless File.file?('conf.yml')
  puts "Please copy conf.yml.example into conf.yml and configure the parameters"
  exit
end
confs = YAML::load(File.open('conf.yml', 'r'))

ClassXClient.new(confs['endpoint_uri'], confs['api_key'], confs['autograders_yml']).run
