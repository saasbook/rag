require_relative 'base'

module Adapter
  class Polling < Base
    attr_accessor :sleep_duration

    def initialize(path, name)
      super(path, name)
      @sleep_duration = conf['sleep_duration'] || 5 * 60
    end

    def run
      while true
        submission = get_submission
        if not submission
          sleep sleep_duration
        else
          graded_submission = @autograder.grade(submission)
          submit_response(graded_submission)
        end
      end
    end

    def connect
    end

    #returns nil if no submission otherwise returns submission object. For XQueue this will be an XQueueSubmission. Others should conform to certain standards. 
    def get_submission
      raise NotImplementedError, "abstract method"
    end

    def submit_response
      raise NotImplementedError, "abstract method"
    end
  end
end
