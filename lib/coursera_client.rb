require 'tempfile'
require 'yaml'
require 'net/http'
require 'base64'

require_relative 'rag_logger'
require_relative 'coursera_controller'
require_relative 'coursera_submission'
require_relative 'auto_grader'
require_relative 'auto_grader_subprocess'

class CourseraClient
  include RagLogger
  include AutoGraderSubprocess

  class CourseraClient::UnknownAssignmentPart < StandardError ; end
  class CourseraClient::SpecNotFound < StandardError ; end

  # Requires a file called 'autograders.yml' to exist in the current working 
  # directory and it must represent a hash from assignment_part_sid's to
  # spec URIs

  #def initialize(endpoint, api_key, autograders_yml)
  def initialize(conf_name=nil)
    conf = load_configurations(conf_name)

    @endpoint = conf['endpoint_uri']
    @api_key = conf['api_key']
    @controller = CourseraController.new(@endpoint, @api_key)
    @halt = conf['halt']
    @sleep_duration = conf['sleep_duration'].nil? ? 5*60 : conf['sleep_duration'] # in seconds

    # Load configuration file for assignment_id->spec map
    # We assume that the keys are also the assignment_part_sids, as well as the queue_ids
    @autograders = init_autograders(conf['autograders_yml'])
  end

  def run
    each_submission do |assignment_part_sid, result|
      submission = decode_submission(result)
      spec = load_spec(assignment_part_sid)
      grader_type = @autograders[assignment_part_sid][:type]

      # FIXME: Use non-subprocess version instead
      begin
        score, comments = run_autograder_subprocess(submission, spec, grader_type) # defined in AutoGraderSubprocess
      rescue AutoGraderSubprocess::SubprocessError => e
        score = 0
        comments = e.to_s
      rescue AutoGraderSubprocess::OutputParseError => e
        score = 0
        comments = e.to_s
      rescue
        logger.fatal(submission)
        raise
      end
      formatted_comments = format_for_html(comments)
      @controller.post_score(result['api_state'], score, formatted_comments)
      logger.debug "  scored #{score}: #{comments}"
    end
  rescue Exception => e
    logger.fatal(e)
    raise
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

  def run_autograder(submission, spec, grader_type)
    g = AutoGrader.create('1', grader_type, submission, :spec => spec)
    g.grade!
    g
  end

  # Returns hash of assignment_part_ids to hashes containing uri and grader type
  # i.e. { "assign-1-part-1" => {:uri => 'http://example.com', :type => 'RspecGrader' } }
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

  def decode_submission(submission)
    case submission['submission_encoding']
    when 'base64'
      Base64.strict_decode64(submission['submission'])
    else
      logger.fatal "Can't handle encoding: #{submission['submission_encoding']}"
      raise "Can't handle encoding: #{submission['submission_encoding']}"
    end
  end

  def each_submission
    if @halt
    # Iterate round robin through assignment parts until all queues are empty
    # parameterize this differently
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

          yield assignment_part_sid, result
        end
        @autograders.delete_if{|key,value| to_delete.include? key}
      end
    else

    # Loop forever
      while true
        all_empty = true
        @autograders.keys.each do |assignment_part_sid|
          logger.info assignment_part_sid
          if @controller.get_queue_length(assignment_part_sid) == 0
            logger.info "  queue length 0"
            next
          end
          all_empty = false
          result = @controller.get_pending_submission(assignment_part_sid)
          next if result.nil?
          logger.info "  received submission: #{result['submission_metadata']['submission_id']}"
          logger.debug result['submission_metadata']

          yield assignment_part_sid, result
        end
        if all_empty
          logger.info "sleeping for #{@sleep_duration} seconds"
          sleep @sleep_duration
        end
      end
    end
  end

  def load_configurations(conf_name=nil)
    config_path = 'config/conf.yml'
    unless File.file?(config_path)
      puts "Please copy conf.yml.example into conf.yml and configure the parameters"
      exit
    end
    confs = YAML::load(File.open(config_path, 'r'){|f| f.read})
    conf_name ||= confs['default'] || confs.keys.first
    conf = confs[conf_name]
    raise "Couldn't load configuration #{conf_name}" if conf.nil?
    conf
  end
end
