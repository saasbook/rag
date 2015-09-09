require_relative 'rspec_grader'

module Graders
  class HerokuRspecGrader < RspecGrader

    ERROR_HASH = {raw_score: 0, raw_max: 100, comments: "File submitted does not contain a URL."}
    def initialize(submission_path, assignment)
      super(submission_path, assignment)
      @timeout = 180
      heroku_file = Dir[File.join(@submission_path, '*')].first  # there should only be on file submitted if its a heroku submission.
      @heroku_uri = IO.read(heroku_file).strip
      @load_student_files = false
    end

    def grade
      begin
        ENV['HEROKU_URI'] = @heroku_uri
        super
      rescue
        ERROR_HASH
      end
    end
  end
end