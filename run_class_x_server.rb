#!/usr/bin/env ruby

require './lib/class_x_controller.rb'
require 'Base64'
require 'json'

server = ClassXController.new('https://berkeley.campus-class.org/saas-staging/', 'iqw9WQi3MgvmOJsK')

assignment_part_id = "course_7_queue_test-assign-part-1"
queue_length = server.get_queue_length(assignment_part_id)
puts queue_length
if queue_length >= 1
  submission = server.get_submission(assignment_part_id)
  #tmp_file = write_temp_file(Base64.strict_decode64(JSON.parse(Base64.strict_decode64(submission['submission']))['submission']))
  #auto_grade(tmp_file)
  unless server.post_score(submission['api_state'], 2)
    puts "Failed"
  else
    puts "Success"
  end
end
