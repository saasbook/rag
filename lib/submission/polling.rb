require_relative 'base'

module SubmissionAdapter
  class Polling < Base
    attr_accessor :sleep_duration

    def initialize(config_hash)
      super(config_hash)
      @sleep_duration = config_hash['sleep_duration'] || 5 * 60
    end

    def run
      loop do
        submission = next_submission_with_assignment
        submission.nil? ? sleep(sleep_duration) : handle_submission(submission)
      end
    end

    def next_submission_with_assignment
      raise NotImplementedError, "abstract method"
    end
  end
end
