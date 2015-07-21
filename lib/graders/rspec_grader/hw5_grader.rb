require_relative 'heroku_rspec_grader.rb'
module Graders
  # hw5 == refactoring_legacy_code
  class HW5Grader < HerokuRspecGrader
    def initialize(submission_path, assignment)
      super(submission_path, assignment)
      temp = @heroku_uri.split(" ")
      @admin_user = temp[1]
      @admin_pass = temp[2]
      @heroku_uri = temp[0]

    end

    def grade
      ENV['ADMIN_USER'] = @admin_user
      ENV['ADMIN_PASS'] = @admin_pass
      super
    end
  end
end
