require_relative 'base'

module Adapter
  class Polling < Base
    attr_accessor :sleep_duration

    def initialize(config_hash)
      super(path, name)
      @sleep_duration = conf['sleep_duration'] || 5 * 60
    end

    def run
      while true
        submission, assignment = get_submission_and_assignment
        if not submission
          sleep sleep_duration
        else
          submission.score, sumbission.message = AutoGraderSubprocess.grade(submission.files, assignment.assignment_spec_uri, assignment.assignment_autograder_type)
          submit_response(submission)
        end
      end
    end

    #returns nil if no submission otherwise returns submission object. For XQueue this will be an XQueueSubmission. Others should conform to certain standards. 
    def get_submission
      raise NotImplementedError "abstract method"
    end

    def submit_response
      raise NotImplementedError "abstract method"
    end
  end
end
