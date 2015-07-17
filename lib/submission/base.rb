require 'yaml'
require 'rag_logger'
require 'byebug'
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
      puts "\n\n\n\n\n------------\n GRADER OUTPUT:\n #{grader_output}\n------------\n\n\n\n\n"
      # byebug
      submission.grade(grader_output[:comments], grader_output[:raw_score], grader_output[:raw_max])
      assignment.apply_lateness! submission  # optionally scales submission by lateness and provides comments.
      submit_response(submission)
    end

    def submit_response(_submission)
      raise NotImplementedError.new('abstract method')
    end
  end
end
