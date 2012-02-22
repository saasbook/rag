#!/usr/bin/env ruby

require 'yaml'
require './lib/coursera_client.rb'

config_path = 'config/conf.yml'
unless File.file?(config_path)
  puts "Please copy conf.yml.example into conf.yml and configure the parameters"
  exit
end
confs = YAML::load(File.open(config_path, 'r'))

if ARGV.size >= 1
  conf_name = ARGV[0]
elsif confs.include? 'default'
  conf_name = confs['default']
else
  conf_name = confs.keys.first
end

conf = confs[conf_name]
raise "Couldn't load configuration #{conf_name}" if conf.nil?

CourseraClient.new(conf['endpoint_uri'], conf['api_key'], conf['autograders_yml']).run
