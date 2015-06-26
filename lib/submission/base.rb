require 'yaml'

module SubmissionAdapter
  class Base
    include RagLogger
    include AutoGraderSubprocess

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
        submission.files.first.last, #for now autograder only can handle one file. This can be easily changed in the future once we refactor the autograder engine
        assignment.assignment_spec_file,
        assignment.autograder_type
      )
      assignment.apply_lateness! submission  # optionally scales submission by lateness and provides comments.
      submit_response(submission)
    end

    def submit_response(_submission)
      raise NotImplementedError, "abstract method"
    end
  end
end
