require_relative 'weighted_rspec_grader'
class CapybaraRspecGrader < WeightedRspecGrader

  # path and grading_rules[:spec] must be absolute paths by this point
  #
  def initialize(path, grading_rules)
    @path = path
    super('', grading_rules)
  end

  def grade!
    Dir.chdir(@path){
      super
    }
  end

end
