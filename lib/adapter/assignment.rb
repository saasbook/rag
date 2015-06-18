require 'json'


module Adapter
  #this class contains both the assignment info extracted from grader_payload as well as the submission itself. Any adapter should be able to grade this type of submission and return a response. 
  class Assignment
    attr_reader :assignment_spec_uri, :assignment_autograder_type

    def initialize(submission)
      raise 'abstract method'
    end

    #default behavior is not to adjust lateness policy. Can be overridden by subclass 
    def apply_lateness_policy(submission)
      submission
    end

  end
end