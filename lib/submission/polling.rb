require_relative 'base'

module Submission
  class Polling < Base
    attr_accessor :sleep_duration

    def initialize(config_hash)
      super(config_hash)
      @sleep_duration = config_hash['sleep_duration'] || 10
    end


    # The main loop for the polling type adapter of submission systems. Calls next_submission_with_assignment, which should be implemented
    # by subclasses and returns a submission with an assignment object.
    # handle_submission is defined in base class of submissions.
    def run
      loop do
        submission = next_submission_with_assignment
        submission.nil? ? sleep(@sleep_duration) : handle_submission(submission)
      end
    end

    def next_submission_with_assignment
      raise NotImplementedError, "abstract method"
    end
  end
end
