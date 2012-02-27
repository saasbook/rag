require 'tempfile'
require 'open3'

require_relative 'rag_logger'

module AutoGraderSubprocess
  extend RagLogger
  class AutoGraderSubprocess::OutputParseError < StandardError ; end
  class AutoGraderSubprocess::SubprocessError < StandardError ; end

  # FIXME: This is a hack, remove later
  # This, and run_autograder, should really be part of a different module/class
  # Runs a separate process for grading
  def self.run_autograder_subprocess(submission, spec, grader_type)
    stdin_text = stdout_text = stderr_text = nil
    Tempfile.open(['test', '.rb']) do |file|
      file.write(submission)
      file.flush
      if grader_type == 'HerokuRspecGrader'
        stdin, stdout, stderr, wait_thr = Open3.popen3 %Q{./grade_heroku "#{submission}" "#{spec}"}
        stdin_text = stdin.read; stdout_text = stdout.read; stderr_text = stderr.read
        stdin.close; stdout.close; stderr.close
      else
        stdin, stdout, stderr, wait_thr = Open3.popen3 %Q{./grade "#{file.path}" "#{spec}"}
        stdin_text = stdin.read; stdout_text = stdout.read; stderr_text = stderr.read
        stdin.close; stdout.close; stderr.close
      end
      if wait_thr.value.exitstatus != 0
        logger.fatal "AutograderSubprocess error: #{stderr_text}"
        raise AutoGraderSubprocess::SubprocessError, "AutograderSubprocess error: #{stderr_text}"
      end
    end

    score, comments = parse_grade(stdout_text)
    comments.gsub!(spec, 'spec.rb')
    [score, comments]
  end

  def run_autograder_subprocess(submission, spec, grader_type)
    AutoGraderSubprocess.run_autograder_subprocess(submission, spec, grader_type)
  end

  # FIXME: This is related to the below hack, remove later
  def self.parse_grade(str)
    # Used for parsing the stdout output from running grade as a shell command
    # FIXME: This feels insecure and fragile
    score_regex = /Score out of 100:\s*(\d+(?:\.\d+)?)$/
    score = str.match(score_regex, str.rindex(score_regex))[1].to_f
    comments = str.match(/^---BEGIN rspec comments---\n#{'-'*80}\n(.*)#{'-'*80}\n---END rspec comments---$/m)[1]
    comments = comments.split("\n").map do |line|
      line.gsub(/\(FAILED - \d+\)/, "(FAILED)")
    end.join("\n")
    [score, comments]
  rescue
    logger.fatal "Failed to parse autograder output: #{str}"
    raise OutputParseError, "Failed to parse autograder output: #{str}"
  end

  def parse_grade(str)
    AutoGraderSubprocess.parse_grade(str)
  end
end
