require 'tempfile'
require 'open3'
require 'timeout'

require_relative 'rag_logger'
require_relative 'run_with_timeout'
require_relative 'escaper'

module AutoGraderSubprocess
  extend RagLogger
  class AutoGraderSubprocess::OutputParseError < StandardError ; end
  class AutoGraderSubprocess::SubprocessError < StandardError ; end

  # FIXME: This is a hack, remove later
  # This, and run_autograder, should really be part of a different module/class
  # Runs a separate process for grading
  def self.run_autograder_subprocess(submission, spec, grader_type)
    stdout_text = stderr_text = nil
    exitstatus = 0
    Tempfile.open(['test', '.rb']) do |file|
      file.write(submission)
      file.flush

      opts = {
        :timeout => 4,
        :cmd => %Q{./grade "#{file.path}" "#{spec}"}
      }.merge case grader_type
      when 'HerokuRspecGrader'
        { :timeout => 180,
          :cmd => %Q{./grade_heroku "#{submission}" "#{spec}"}
        }
      when 'GithubRspecGrader'
        { :timeout => 180,
          :cmd => %Q{./new_grader -t GithubRspecGrader "#{submission}" "#{spec}"}
        }
      when 'HW3Grader'
        {
          :timeout => 400,
          :cmd => %Q{./grade3 -a ../rottenpotatoes "#{file.path}" "#{spec}"}
        }
      when 'HW4Grader'
        {
          :timeout => 300,
          :cmd => %Q{./grade4 "#{file.path}" "#{spec}"}
        }
      when 'HW5Grader'
        submission = escape_all_fields(submission)
        {
          :timeout => 300,
          :cmd => %Q{./grade5 #{submission} "#{spec}"}
        }
      when 'MigrationGrader'
        {
          :timeout => 300,
          :cmd => %Q{./grade6 "#{file.path}" "#{spec}"}
        }
      else
        {}
      end

      begin
        stdout_text, stderr_text, exitstatus = run_with_timeout(opts[:cmd], opts[:timeout])
      rescue Timeout::Error => e
        exitstatus = -1
        stderr_text = "Program timed out"
      end

      if exitstatus != 0
        logger.fatal "AutograderSubprocess error: #{stderr_text}"
        raise AutoGraderSubprocess::SubprocessError, "AutograderSubprocess error: #{stderr_text}"
      end
    end
    score, comments = parse_grade(stdout_text)
    comments.gsub!(spec, 'spec.rb')
    [score, comments]
  rescue ArgumentError => e
    logger.error e.to_s
    score = 0
    comments = e.to_s
    [score, comments]
  end

  def run_autograder_subprocess(submission, spec, grader_type)
    AutoGraderSubprocess.run_autograder_subprocess(submission, spec, grader_type)
  end

  SCORE_REGEX = /Score out of \d+:\s*(\d+(?:\.\d+)?)$/
  COMMENT_REGEX = /---BEGIN (?:cucumber|rspec|grader) comments---\n#{'-'*80}\n(.*)#{'-'*80}\n---END (?:cucumber|rspec|grader) comments---/m

  # FIXME: This is related to the below hack, remove later
  def self.parse_grade(str)
    # Used for parsing the stdout output from running grade as a shell command
    # FIXME: This feels insecure and fragile

    score = str.match(SCORE_REGEX, str.rindex(SCORE_REGEX))[1].to_f
    comments = str.match(COMMENT_REGEX)[1]
    comments = comments.split("\n").map do |line|
      line.gsub(/\(FAILED - \d+\)/, "(FAILED)")
    end.join("\n")
    [score, comments]
  rescue ArgumentError => e
    logger.error "Error running parse_grade: #{e.to_s}; #{str}"
    [0, e.to_s]
  rescue StandardError => e
    logger.fatal "Failed to parse autograder output: #{e.to_s}; #{str}"
    raise OutputParseError, "Failed to parse autograder output: #{str}"
  end

  def parse_grade(str)
    AutoGraderSubprocess.parse_grade(str)
  end
end
