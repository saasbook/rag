require 'tempfile'
require 'yaml'
require 'net/http'
require 'Base64'
require 'open3'

require_relative 'rag_logger'
require_relative 'coursera_controller'
require_relative 'coursera_submission'
require_relative 'auto_grader'

class CourseraClient
  include RagLogger

  class CourseraClient::UnknownAssignmentPart < StandardError ; end
  class CourseraClient::SpecNotFound < StandardError ; end

  # Requires a file called 'autograders.yml' to exist in the current working 
  # directory and it must represent a hash from assignment_part_sid's to
  # spec URIs

  def initialize(endpoint, api_key, autograders_yml)
    @endpoint = endpoint
    @api_key = api_key
    @controller = CourseraController.new(endpoint, api_key)

    # Load configuration file for assignment_id->spec map
    # We assume that the keys are also the assignment_part_sids, as well as the queue_ids
    @autograders = init_autograders(autograders_yml)
  end

  def run
    # Iterate round robin through assignment parts until all queues are empty
    while @autograders.size > 0
      to_delete = []
      @autograders.keys.each do |assignment_part_sid|
        logger.info assignment_part_sid
        if @controller.get_queue_length(assignment_part_sid) == 0
          logger.info "  queue length 0; removing"
          to_delete << assignment_part_sid
          next
        end
        result = @controller.get_pending_submission(assignment_part_sid)
        next if result.nil?
        logger.info "  received submission: #{result['submission_metadata']['submission_id']}"
        logger.debug result['submission_metadata']

        if result['submission_encoding'] != 'base64'
          logger.fatal "Can't handle encoding: #{result['submission_encoding']}" 
          raise "Can't handle encoding: #{result['submission_encoding']}" 
        end
        submission = Base64.strict_decode64(result['submission'])
        spec = load_spec(assignment_part_sid)
        grader_type = @autograders[assignment_part_sid][:type]

        # Original method
        #grade = run_autograder(submission, spec, grader_type)
        #score = grade.normalized_score
        #comments = grade.comments

        # FIXME: Run as subprocess
        score, comments = run_autograder_subprocess(submission, spec, grader_type)
        formatted_comments = format_for_html(comments)
        @controller.post_score(result['api_state'], score, formatted_comments)

        logger.debug "  scored #{score}: #{comments}"
      end

      @autograders.delete_if{|key,value| to_delete.include? key}
    end
  end

  def download_submissions(file)
    # Iterate through assignment parts until all queues are empty
    # Note, this process MUST complete in under 15 minutes or else the queues
    # will start repopulating. This method does NOT permanently remove 
    # submissions from the queue
    if file.nil?
      logger.fatal 'Target file is nil'
    end
    submissions = {}
    @autograders.each_key {|x| submissions[x] = []}

    @autograders.keys.each do |assignment_part_sid|
      while true
        if @controller.get_queue_length(assignment_part_sid) == 0
          logger.info "  deleting assignment part"
          break
        end
        result = @controller.get_pending_submission(assignment_part_sid)
        next if result.nil?
        logger.info "  got submission"
        submissions[assignment_part_sid] << result
      end
    end
    logger.info "Finishing"
    file.write(submissions.inspect)
    file.flush
  end

  private

  def load_spec(assignment_part_sid)
    unless @autograders.include?(assignment_part_sid)
      logger.fatal "Assignment part #{assignment_part_sid} not found!"
      raise "Assignment part #{assignment_part_sid} not found!"
    end
    autograder = @autograders[assignment_part_sid]
    return autograder[:uri] if autograder[:uri] !~ /^http/ # Assume that if uri doesn't start with http, then it is a local file path

    # If not in cache, download and add to cache
    if autograder[:cache].nil?
      spec_file = Tempfile.new('spec')
      response = Net::HTTP.get_response(URI(autograder[:uri]))
      if response.code !~ /2\d\d/
        logger.fatal "Could not load the spec at #{autograder[:uri]}"
        raise CourseraClient::SpecNotFound, "Could not load the spec at #{autograder[:uri]}"
      end
      spec_file.write(response.body)
      spec_file.close
      autograder[:cache] = spec_file
    end
    autograder[:cache].path
  end

  # FIXME: This is related to the below hack, remove later
  def parse_grade(str)
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
    raise "Failed to parse autograder output: #{str}"
  end

  # FIXME: This is a hack, remove later
  # Runs a separate process for grading
  def run_autograder_subprocess(submission, spec, grader_type)
    stdout = ''
    Tempfile.open(['test', '.rb']) do |file|
      file.write(submission)
      file.flush
      if grader_type == 'HerokuRspecGrader'
        stdin, stdout, stderr = Open3.popen3(%Q{./grade_heroku "#{submission}" #{spec}})
      else
        stdin, stdout, stderr = Open3.popen3(%Q{./grade #{file.path} #{spec}})
      end
      if $?.to_i != 0
        logger.fatal "AutograderSubprocess error: #{stderr}"
        raise 'AutograderSubprocess error'
      end
    end

    score, comments = parse_grade(stdout)
    comments.gsub!(spec, 'spec.rb')
    [score, comments]
  end

  def run_autograder(submission, spec, grader_type)
    g = AutoGrader.create('1', grader_type, submission, :spec => spec)
    g.grade!
    g
  end

  # Returns hash of assignment_part_ids to hashes containing uri and grader type
  def init_autograders(filename)
    # TODO: Verify file format
    yml = YAML::load(File.open(filename, 'r'))
    yml.each_pair do |id, obj|
      # Convert keys from string to sym
      yml[id] = obj.inject({}){|memo, (k,v)| memo[k.to_sym] = v; memo}
    end
  end

  # Formats autograder ouput for display in browser
  def format_for_html(text)
    "<pre>#{text.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;')}</pre>" # sanitize html
    #  .gsub(/^(  +)/){|s| "&nbsp;"*s.size} # indentation
    #  .gsub(/\n/, "<br />\n") # newlines
  end
end
