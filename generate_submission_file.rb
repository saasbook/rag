#!/usr/bin/env ruby

require 'json'
require 'base64'
require './lib/class_x_submission.rb'

unless (3..4).include? ARGV.length
  puts "Usage: #{$0} assignment_part_sid email_address input_file <output_file=output.txt>"
  exit
end

assignment_part_sid = ARGV[0]
email_address = ARGV[1]
input_file = ARGV[2]
output_file = ARGV.length == 4 ? ARGV[3] : 'output.txt'

input_file_text = File.open(input_file, 'r') {|f| f.read}
submission = ClassXSubmission.new(assignment_part_sid, email_address, input_file_text)
File.open(output_file, 'w') {|f| f.write(Base64.strict_encode64(submission.to_json))}
puts "Output successfully written to #{output_file}."
