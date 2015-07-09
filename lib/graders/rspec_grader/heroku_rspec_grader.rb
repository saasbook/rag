require_relative 'rspec_grader'

module Graders
  class HerokuRspecGrader < RspecGrader
    def initialize(uri, grading_rules)
      super('', grading_rules)
      @heroku_uri = uri
    end

    def grade
      ENV['HEROKU_URI'] = @heroku_uri
      super
    end
  end
end