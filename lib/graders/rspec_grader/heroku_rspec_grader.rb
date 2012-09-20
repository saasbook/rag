require_relative 'weighted_rspec_grader'

class HerokuRspecGrader < WeightedRspecGrader
  def initialize(uri, grading_rules)
    super('', grading_rules)
    @heroku_uri = uri
  end

  def grade!
    ENV['HEROKU_URI'] = @heroku_uri
    super
  end
end
