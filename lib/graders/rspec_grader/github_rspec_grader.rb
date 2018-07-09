require_relative 'rspec_grader'


module Graders
  class GithubRspecGrader < RspecGrader
    def initialize(submission_path, assignment)
      super('', assignment)
      @timeout = 180
      @load_student_files = false
      username = File.open(submission_path, &:readline)
      ENV['GITHUB_USERNAME'] = username.strip.delete("\n")
      # http://github.com/username/assignment_name is the uri?
    end
  end
end