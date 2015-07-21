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

  # versioning
  class Xqueue < Base
    def initialize(submission)
      grader_payload = submission.grader_payload
      @assignment_name = grader_payload['assignment_name']
      @assignment_spec_file = fetch_spec_file(grader_payload['assignment_spec_uri'])
      @autograder_type = grader_payload['autograder_type']
      @due_dates = grader_payload['due_dates'].map {|key, value| TimeBracket.create_time_bracket(key, value)}.sort
    end

    def apply_lateness!(submission)
      submission_time = submission.submission_time
      submit_range = @due_dates.map {|due_date| submission_time < due_date}.find_index(true) #return index of which date range submission falls into. if nil,
      puts "Due dates: #{@due_dates.inspect} \n Submission index = #{submit_range}"
      grade_scale = submit_range ? @due_dates[submit_range].point_scaling : 0
      submission.score = grade_scale * submission.score
      submission.message = "Submission recorded at  #{submission_time} with #{grade_scale} penalty\n" + submission.message
      submission
    end

    private
    # Get the spec file from grader payload download URI unless it already exists. Returns a file path.
    def fetch_spec_file(spec_uri)
      Dir.mkdir ENV['base_folder'] unless Dir.exist? ENV['base_folder']
      file_path = "#{ENV['base_folder']}#{@assignment_name}-spec"
      if File.exist? file_path
        File.open file_path
      else
        session = Mechanize.new
        File.open(file_path, 'w') { |f| f.write(session.get(spec_uri).body); f }
      end
      file_path
    end

  end

  # convenience mixin for managing submission times and point scalings
  module TimeBracket
    attr_accessor :point_scaling
    def self.create_time_bracket(time_string, scaling)
      time = Time.parse(time_string).extend(TimeBracket)
      time.point_scaling = scaling
      time
    end
  end
end
