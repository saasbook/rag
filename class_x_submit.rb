#!/usr/bin/env ruby

require 'json'
require 'base64'

class ClassXSubmission
  attr_accessor :assignment_part_sid, :email_address, :submission, :submission_aux

  def initialize(assignment_part_sid, email_address, submission, submission_aux="")
    @assignment_part_sid = assignment_part_sid
    @email_address = email_address
    @submission = submission
    @submission_aux = submission_aux
  end

  def to_json
    obj = {
      :assignment_part_sid => Base64.strict_encode64(@assignment_part_sid),
      :email_address => Base64.strict_encode64(@email_address),
      :submission => Base64.strict_encode64(@submission),
      :submission_aux => Base64.strict_encode64(@submission_aux),
    }
    obj.to_json
  end
end

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
