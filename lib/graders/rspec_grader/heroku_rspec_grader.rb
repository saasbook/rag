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

    def runner_block
      begin
        raw_score, raw_max, comments = compute_points(@spec_file_path)
      rescue Exception => e
        raise e
      end
      @output_hash = {raw_score: raw_score, raw_max: raw_max, comments: comments}
    end
  end
end