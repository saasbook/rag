require_relative 'rspec_grader'
module Graders
  class WeightedRspecGrader < RspecGrader
    def grade
      ## TEMP REFACTOR, EVENTUALLY DEPRECATE
      super(true)
    end
  end
end
