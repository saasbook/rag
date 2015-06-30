require 'yaml'

module Submission
  class Base
    include RagLogger
    include AutoGraderSubprocess

    def initialize(_config_hash)
      # raise NotImplementedError.new "abstract method"
    end

    def run
      raise NotImplementedError, 'abstract method'
    end

    def handle_submission(submission)
      raise 'No submission received' if submission.nil?
      assignment = submission.assignment
      submission.score, submission.message =
      Graders::AutoGrader.create(submission.files, assignment)
      assignment.apply_lateness! submission  # optionally scales submission by lateness and provides comments.
      submit_response(submission)
    end

    def submit_response(_submission)
      raise NotImplementedError.new('abstract method')
    end
  end
end
