require 'json'
require 'active_support'
require 'active_support/all' #lazy loading so this should be OK.
require_relative 'assignment'

module Adapter
  #this class contains both the assignment info extracted from grader_payload as well as the submission itself. Any adapter should be able to grade this type of submission and return a response. 
  class XQueueAssignment < Assignment
    include ActiveModel::Validations

    validates_presence_of :due_date, :assignment_name, :assignment_spec_uri,  :assignment_autograder_type

    ON_TIME = 0
    GRACE_PERIOD = 1
    LATE_PERIOD = 2
    TOO_LATE = 3
    GRADE_SCALING = [1.0, 0.75, 0.50, 0.0]

    def initialize(submission)
      grader_payload = submission.grader_payload
      @assignment_name = grader_payload['assignment_name']
      @assignment_spec_uri = grader_payload['assignment_spec_uri']
      @assignment_autograder_type = grader_payload['assignment_autograder_type']
      @due_date = Time.parse(grader_payload['due_date'])
      grace_period = (grader_payload['grace_period'] || 8).days
      late_period = (grader_payload['late_period'] || 0).days
      @due_dates = [@due_date, @due_date + grace_period, @due_date + grace_period + late_period]
    end

    def apply_lateness(submission)
      submission_time = submission.submission_time
      submit_range = @due_dates.map {|due_date| submission_time < due_date}.find_index(true) || @due_dates.size #return index of which date range submission falls into
      grade_scale = GRADE_SCALING[submit_range]
      submission.score = grade_scale * submission.score
      case submit_range
      when ON_TIME
        submission.message = "On time\n" + submission.message
      when GRACE_PERIOD
        submission.message = "Submitted during grace period with #{grade_scale} penalty\n" + submission.message
      when LATE_PERIOD
        submission.message = "Submitted during late period with #{grade_scale} penalty\n" + submission.message
      else
        submission.message = "Submitted past late period with #{grade_scale} penalty\n" + submission.message
      end
      submission
    end

  end

end