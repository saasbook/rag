require_relative 'weighted_rspec_grader'

class GithubRspecGrader < WeightedRspecGrader
  def initialize(username, grading_rules)
    super('', grading_rules)
    ENV['GITHUB_USERNAME'] = username.strip.delete("\n")
  end

  def self.cli(args)
    RspecGrader::cli args
  end
end
