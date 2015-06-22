require 'json'
require 'date'
require 'active_support'
require 'active_support/all' # lazy loading so this should be OK.
require 'mechanize'
require_relative 'base'


module Assignment
  # this class contains both the assignment info extracted from grader_payload
  # as well as the submission itself. Any adapter should be able to grade this
  # type of submission and return a response.
  class Xqueue < Base
    def initialize(submission)
      grader_payload = submission.grader_payload
      @assignment_name = grader_payload['assignment_name']
      @assignment_spec_file = fetch_spec_file(grader_payload['assignment_spec_uri'])
      @assignment_autograder_type = grader_payload['assignment_autograder_type']
      @due_date = Time.parse(grader_payload['due_date'])
      grace_period = (grader_payload['grace_period'] || 8).days
      late_period = (grader_payload['late_period'] || 0).days
      @latenesses = [
        { name: 'on time',
          cutoff: @due_date,
          grade_scaling: 1.0,
          submission_message: "On time" },
        { name: 'grace period',
          cutoff: @due_date + grace_period,
          grade_scaling: 0.75,
          submission_message: "Submitted during grace period with 0.25 penalty" },
        { name: 'late period',
          cutoff: @due_date + grace_period + late_period,
          grade_scaling: 0.50,
          submission_message: "Submitted during late period with 0.50 penalty" },
        { name: 'too late',
          cutoff: :never,
          grade_scaling: 0.0,
          submission_message: "Submitted past late period with 1.0 penalty" }
      ]
    end

    def apply_lateness!(submission)
      lateness = lateness_by_time(submission.submission_time)
      submission.score *= lateness[:grade_scaling]
      submission.message = lateness[:submission_message] + "\n" + submission.message
    end

    private

    def lateness_by_time(submission_time)
      raise "nil submission_time" if submission_time.nil?
      @latenesses.each do |lateness|
        return lateness if lateness[:cutoff] == :never
        return lateness if submission_time < lateness[:cutoff]
      end
      raise ScriptError
    end

    def fetch_spec_file(spec_uri)
      session = Mechanize.new
      file = File.open('spec_file.rb', 'w') do |f| 
        f.write(session.get(spec_uri).body)
        f.rewind
        f
      end
      raise 'yolo' unless File.readable?(file.path)
      file.path
    end
  end
end
