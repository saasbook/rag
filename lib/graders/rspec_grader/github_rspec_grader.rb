require_relative 'weighted_rspec_grader'

class GithubRspecGrader < WeightedRspecGrader
  def initialize(username, grading_rules)
    super('', grading_rules)
    ENV['GITHUB_USERNAME'] = username.strip.delete("\n")
  end

  def self.format_cli(t_option, type, username, specs)
    # refuse parent IO file read, use grandparent
    return RspecGrader.format_cli(t_option, type, username, specs)
  end
end

