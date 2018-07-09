require_relative 'rspec_grader'


module Graders
  class GithubRspecGrader < RspecGrader
    def initialize(submission_path, assignment)
      super(submission_path, assignment)
      @timeout = 180
      @load_student_files = false
      github_file = Dir[File.join(@submission_path, '*')].first  # there should only be one file submitted if its a github submission.
      ENV['GITHUB_USERNAME'] = IO.read(github_file).strip.delete("\n")
      # http://github.com/username/assignment_name is the uri?
    end
  end
end