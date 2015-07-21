require_relative 'rspec_grader'


module Graders
  class GithubRspecGrader < RspecGrader
    def initialize(username, assignment)
      super('', assignment)
      @timeout = 180
      @load_student_files = false
      ENV['GITHUB_USERNAME'] = username.strip.delete("\n")
      # http://github.com/username/assignment_name is the uri?
    end
  end
end