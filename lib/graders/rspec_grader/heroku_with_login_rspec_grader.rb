require_relative 'heroku_rspec_grader'

module Graders
  class HerokuWithLoginRspecGrader < HerokuRspecGrader

    def initialize(submission_path, assignment)
      super(submission_path, assignment)
      temp = @heroku_uri.split(" ")
      begin
        @admin_user = temp[1]
        @admin_pass = temp[2]
        @heroku_uri = temp[0]
      rescue
        # Do nothing. We know this will fail but systematically all graders should only fail at the grade step.
      end
    end

    def grade
      begin
        ENV['ADMIN_USER'] = @admin_user
        ENV['ADMIN_PASS'] = @admin_pass
      super
      rescue
        ERROR_HASH
      end
    end
  end
end