require_relative 'rspec_grader'


module Graders
  class GithubRspecGrader < RspecGrader
    def initialize(username, grading_rules)
      super('', grading_rules)
      ENV['GITHUB_USERNAME'] = username.strip.delete("\n")
    end
  end
end