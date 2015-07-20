require_relative 'rspec_grader'

module Graders
  class HerokuRspecGrader < RspecGrader
    def initialize(submission_path, assignment)
      super(submission_path, assignment)
      @timeout = 60
      heroku_file = Dir[File.join(@submission_path, '*.rb')].first  # there should only be on file submitted if its a heroku submission.
      @heroku_uri = IO.read(heroku_file).strip
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