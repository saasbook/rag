#!/usr/bin/env ruby

require './lib/class_x_client.rb'

endpoint_uri = 'https://berkeley.campus-class.org/saas-staging/'
api_key = ''
if api_key.blank?
  puts 'You must edit this script and add in the api_key. This can be found on the Course Settings administrative page.'
  exit
end
queue_id = "course_7_queue_test-assign-part-1"

ClassXClient.new(endpoint_uri, api_key, queue_id).run
