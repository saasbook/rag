require 'yaml'
require 'byebug'
require_relative '../rag_logger'
module Submission
  class Base
    include RagLogger
    def initialize(config_hash)
      RagLogger.configure_logger(config_hash['log_file']) if config_hash['log_file'].present?
    end
    def run
      raise NotImplementedError, 'abstract method'
    end

    def handle_submission(submission)
      raise 'No submission received' if submission.nil?
      assignment = submission.assignment
      grader = Graders::AutoGrader.create(submission.files.values.first, assignment)
      grader_output = grader.grade
      submission.grade!(grader_output[:comments], grader_output[:raw_score], grader_output[:raw_max])
      assignment.apply_lateness! submission  # optionally scales submission by lateness and provides comments.
      logger.debug "SUBMISSION MESSAGE = #{submission.message}"
      submit_response(submission)
    end
    def submit_response(_submission)
      raise NotImplementedError.new('abstract method')
    end
  end
end
