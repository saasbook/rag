require_relative 'weighted_rspec_grader'

class GithubRspecGrader < WeightedRspecGrader
  def initialize(username, grading_rules)
    super('', grading_rules)
    ENV['GITHUB_USERNAME'] = username
  end
end
