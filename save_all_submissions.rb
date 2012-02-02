#!/usr/bin/env ruby

require 'yaml'
require './lib/class_x_client.rb'

unless File.file?('conf.yml')
  puts "Please copy conf.yml.example into conf.yml and configure the parameters"
  exit
end
confs = YAML::load(File.open('conf.yml', 'r'))

if ARGV.size >= 1
  conf_name = ARGV[0]
elsif confs.include? 'default'
  conf_name = confs['default']
else
  conf_name = confs.keys.first
end

conf = confs[conf_name]
raise "Couldn't load configuration #{conf_name}" if conf.nil?

f = File.open('submissions', 'w')
ClassXClient.new(conf['endpoint_uri'], conf['api_key'], conf['autograders_yml']).download_submissions(f)
f.close
