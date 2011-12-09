class BeautifulCodeGrader < AutoGrader

  def initialize(submitted_answer, grading_rules)
    @submitted_answer = submitted_answer
    @grading_rules = grading_rules
    @normalized_score = 0.0
    @comment = ''
  end

end
