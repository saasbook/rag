require_relative 'rspec_grader'

module Graders
  class HerokuRspecGrader < RspecGrader
    def initialize(submission_path, assignment)
      super(submission_path, assignment)
      @timeout = 180
      heroku_file = Dir[File.join(@submission_path, '*')].first  # there should only be on file submitted if its a heroku submission.
      @heroku_uri = IO.read(heroku_file).strip
      @load_student_files = false
    end

    def grade
      ENV['HEROKU_URI'] = @heroku_uri
      super
    end
  end
end