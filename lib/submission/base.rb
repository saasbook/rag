require 'yaml'
require 'byebug'
require_relative '../rag_logger'
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
      grader = Graders::AutoGrader.create(submission.files.values.first, assignment)
      grader_output = grader.grade
      assignment.apply_lateness! submission  # optionally scales submission by lateness and provides comments.
      submission.grade!(grader_output[:comments], grader_output[:raw_score], grader_output[:raw_max])
      logger.debug "SUBMISSION MESSAGE = #{submission.message}"
      submit_response(submission)
    end
    def submit_response(_submission)
      raise NotImplementedError.new('abstract method')
    end
  end
end
