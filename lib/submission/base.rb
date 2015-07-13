require 'yaml'
require 'rag_logger'

module Submission
  class Base
    include RagLogger

    def initialize(_config_hash)
    end

    def run
      raise NotImplementedError, 'abstract method'
    end

    def handle_submission(submission)
      raise 'No submission received' if submission.nil?
      assignment = submission.assignment
      #
      graded = Graders::AutoGrader.create(submission.files, assignment).grade
      #
      submission.score, submission.message = graded[:points_received], graded[:comments]
      assignment.apply_lateness! submission  # optionally scales submission by lateness and provides comments.
      submit_response(submission)
    end

    def submit_response(_submission)
      raise NotImplementedError.new('abstract method')
    end
  end
end
