require 'yaml'
require 'byebug'
require_relative '../rag_logger'
module Submission
  class Base
    include RagLogger

    #start with logger if user specifies a log file.
    def initialize(config_hash)
      RagLogger.configure_logger(config_hash['log_file'], config_hash['log_level'] || 0)  # if log_file not present or false, then logs to STDOUT
    end
    def run
      raise NotImplementedError, 'abstract method'
    end

    def handle_submission(submission)
      raise 'No submission received' if submission.nil?
      assignment = submission.assignment
      grader = Graders::AutoGrader.create(submission.files.values.first, assignment)  # edX XQueue API only supports 1 file at a time, so grab that
      grader_output = grader.grade
      submission.message = ''  # There's no reason why I should have to do this, but this is a bug that I can't seem to trace down.
      submission.grade!(grader_output[:comments], grader_output[:raw_score], grader_output[:raw_max])
      assignment.apply_lateness! submission  # optionally scales submission by lateness and provides comments.
      puts "Submission message after grade: #{submission.message}"
      logger.debug "submission message = #{submission.message}"
      submit_response(submission)
    end
    def submit_response(_submission)
      raise NotImplementedError.new('abstract method')
    end
  end
end