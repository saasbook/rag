require 'yaml'

module Adapter
  class Base
    include RagLogger
    include AutoGraderSubprocess
    attr_accessor :conf, :autograder_hash

    def initialize(_config_hash)
      # raise NotImplementedError.new "abstract method"
    end

    def run
      raise NotImplementedError, "abstract method"
    end

    def handle_submission(submission)
      raise "nil submission received" if submission.nil?
      assignment = submission.assignment
      submission.score, submission.message =
      AutoGraderSubprocess.run_autograder_subprocess(
        submission.files[0],
        assignment.assignment_spec_file,
        assignment.assignment_autograder_type
      )
      assignment.apply_lateness! submission  # optionally scales submission by lateness and provides comments.
      submit_response(submission)
    end

    def submit_response(_submission)
      raise NotImplementedError, "abstract method"
    end
  end
end
