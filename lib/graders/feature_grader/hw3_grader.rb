require_relative 'feature_grader'

#TODO functions only on archive with everything, does not add solution to student archive. See HW4Grader.grade!
class HW3Grader < FeatureGrader

  @assignment_id = '3'

  @multithread   = true

  def self.format_cli(t_option, type, a_option, base_app_path, archive, hw3_yml)
    spec_hash = {:description => hw3_yml}
    spec_hash[:mt] = @multithread
    return @assignment_id, type, archive, spec_hash
  end

  def self.feedback(completed_grader)
    g = completed_grader
    score_max = 500
    score_msg = "Score out of #{score_max}: #{g.normalized_score(score_max)}\n"
    comments_msg = "---BEGIN cucumber comments---\n#{'-'*80}\n#{g.comments}\n#{'-'*80}\n---END cucumber comments---"
    return comments_msg + score_msg
  end

end
