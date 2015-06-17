require 'json'


module Adapter
  #this class contains both the assignment info extracted from grader_payload as well as the submission itself. Any adapter should be able to grade this type of submission and return a response. 
  class XQueueAssignment < Assignment

    def initialize(submission)
      @submission = submission
      grader_payload = JSON.parse(submission.grader_payload)
      @assignment_name = grader_payload['assignment_name']
      @assignment_spec_uri = grader_payload['assignment_spec_uri']
      @assignment_autograder_type = grader_payload['assignment_autograder_type']
    end

  end
end