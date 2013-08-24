#TODO need to figure out what these queues are named

require 'tempfile'
require 'yaml'
require 'net/http'
require 'base64'
require 'cgi'
require 'date'

require_relative 'rag_logger'
require_relative 'edx_controller'
require_relative 'edx_submission'
require_relative 'auto_grader'
require_relative 'auto_grader_subprocess'

class EdXClient
  include RagLogger
  include AutoGraderSubprocess

  attr_reader :name

  class EdXClient::UnknownAssignmentPart < StandardError ; end
  class EdXClient::SpecNotFound < StandardError ; end

  # Requires a file called 'autograders.yml' to exist in the current working 
  # directory and it must represent a hash from assignment_part_sid's to
  # spec URIs

  def initialize(conf_name=nil)
    conf = EdXClient.load_configurations(conf_name)
    @endpoint = conf['queue_uri'] 

    @user_auth=conf['user_auth'].values
    @django_auth=conf['django_auth'].values

    @controller = EdXController.new(*@django_auth,*@user_auth,@name, @endpoint)
    @halt = conf['halt']
    @sleep_duration = conf['sleep_duration'].nil? ? 5*60 : conf['sleep_duration'] # in seconds

    # Load configuration file for assignment_id->spec map

    @autograders = EdXClient.init_autograders(conf['autograders_yml'])
    @name = @autograders.values.first[:name]
  end

  def run
#later make one package here.
    each_submission do |assignment_part_sid, submission,part_name,student_info|
      submission_time=student_info["submission_time"]
      user_id=student_info["anonymous_student_id"]
      spec,grader_type = load_spec(assignment_part_sid,part_name)
      due_date =load_due_date(assignment_part_sid)
      grace_period=load_grace_period(assignment_part_sid)
      late_scale,late_comments=generate_late_response(submission_time,due_date,grace_period)
      logger.info "Lateness scaling factor is #{late_scale}"
      write_student_submission(user_id,submission,part_name)
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

      comments= late_comments.to_s + " " + comments.to_s
      get_checkmark=true
 
      if score == 0 or score == 0.0
        get_checkmark=false
      end
      score=late_scale*score
      formatted_comments = format_for_html(comments)
      @controller.send_grade_response(get_checkmark, score, formatted_comments) #figure out better thing for true later
      logger.debug "  scored #{score}: #{comments}"
    end
  rescue Exception => e
    logger.fatal(e)
    raise
  end

  
#begin private functions
  private
  #this works for grouped assignments
  def load_due_date(assignment_part_sid)
    
    unless @autograders.include?(assignment_part_sid)
      logger.fatal "Assignment part #{assignment_part_sid} not found!"
      raise "Assignment part #{assignment_part_sid} not found!"
    end
    due= @autograders[assignment_part_sid][:due]   
    due ||= 20250910031500 #if no due date is given choose one in 2025 FIX Before 2025
  end

  def load_grace_period(assignment_part_sid)
    
    unless @autograders.include?(assignment_part_sid)
      logger.fatal "Assignment part #{assignment_part_sid} not found!"
      raise "Assignment part #{assignment_part_sid} not found!"
    end
    grace= @autograders[assignment_part_sid][:grace_period]
    grace=grace.to_i unless grace.nil?   
    grace ||= 8 #if no grace period is found choose 1 week +24 hours
  end
  
  def generate_late_response(received_date, due_date,grace_period)
    received_time=DateTime.parse(received_date.to_s)
    due_time=DateTime.parse(due_date.to_s)
    lateness=received_time-due_time
    lateness=lateness.to_f #we might lose some precision but oh well
    #should really be a case statement
    return [1.0, "On Time"] unless lateness > 0
    
    return [0.75, "Late assignment: score scaled by .75\n"] unless lateness > grace_period
    
    return [0.5, "Between one and two days late: score scaled by: .5\n"] unless lateness > (grace_period +1)
    
    return [0.0, "More than two days late: no points awarded\n"]
  end

  def load_spec(assignment_part_sid,part_id)
    unless @autograders.include?(assignment_part_sid) 
      logger.fatal "Assignment part #{assignment_part_sid} not found!"
      raise "Assignment part #{assignment_part_sid} not found!"
    end

    unless  @autograders[assignment_part_sid][:parts].include?(part_id)
      logger.fatal "Assignment part #{part_id} not found!"
      raise "Assignment part #{part_id} not found!"
    end
  
    autograder = @autograders[assignment_part_sid][:parts][part_id]#prettify later
    
    return [autograder["uri"],autograder["type"]] if autograder["uri"] !~ /^http/ # Assume that if uri doesn't start with http, then it is a local file path

    # If not in cache, download and add to cache
    if autograder[:cache].nil?
      spec_file = Tempfile.new('spec')
      response = Net::HTTP.get_response(URI(autograder[:uri]))
      if response.code !~ /2\d\d/
        logger.fatal "Could not load the spec at #{autograder[:uri]}"
        raise EdXClient::SpecNotFound, "Could not load the spec at #{autograder[:uri]}"
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
  # i.e. { "assign-1-part-1" => {:uri => 'solutions/part1_spec.rb', :type => 'RspecGrader' } }
  def self.init_autograders(filename)
    # TODO: Verify file format
    yml = YAML::load(File.open(filename, 'r'))
    yml.each_pair do |id, obj|
      # Convert keys from string to sym
      yml[id] = obj.inject({}){|memo, (k,v)| memo[k.to_sym] = v; memo}
    end
  end

  # Formats autograder ouput for display in browser
  def format_for_html(text)
    "<pre>#{CGI::escape_html(text)}</pre>" # sanitize html
  end


  def each_submission
    if @halt
    #CRITICAL this does not work with halt for edX 
    #todo fix 
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
          logger.info "  received submission: #{result.inspect}"
          @xheader = result['xqueue_header']
          @xbody = result['xqueue_body']
          @xfiles = result['xqueue_files'] #his is a url
          
          yield assignment_part_sid, result[:file], result[:part_name]
        end
        @autograders.delete_if{|key,value| to_delete.include? key}
      end
    else

    # Loop forever
      while continue_running_test(@controller.get_queue_length())
        all_empty = true
        @autograders.keys.each do |assignment_part_sid|        
          q_name=@autograders[assignment_part_sid][:name]
          @controller.set_queue_name(q_name)
          logger.info assignment_part_sid
          logger.info "using queue #{q_name}"
          @controller.authenticate
          if @controller.get_queue_length() == 0 #pass this in later
            logger.info "  queue length 0"
            next
          end
          all_empty = false
          result = @controller.get_submission()
          next if result.nil?
          yield assignment_part_sid, result[:file], result[:part_name],result[:student_info]
        end
        if all_empty
          logger.info "sleeping for #{@sleep_duration} seconds"
          sleep @sleep_duration
        end
      end
    end
  end

  def self.load_configurations(conf_name=nil)
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

  def write_student_submission(user_id,content,part_name)
    dir_name="log/#{part_name}-submissions"
   # puts "dirName is #{dir_name}"
    Dir.mkdir('log/') unless File.directory?('log/')
    Dir.mkdir(dir_name) unless File.directory?(dir_name)
   
    submission_attempt=1    
    file_name=user_id.to_s + "_attempt_"+submission_attempt.to_s    
   # puts "file_name is #{file_name}"
    file_path=File.join(dir_name,file_name)
   # puts "file_path is #{file_path}"

    while File.exists?(file_path)
      submission_attempt +=1
    
      file_name=user_id.to_s + "_attempt_"+submission_attempt.to_s    
    #  puts "file_name is #{file_name}"
      file_path=File.join(dir_name,file_name)
     # puts "file_path is #{file_path}"    
    end
    begin
      out=File.new(file_path,"w")
      out.write(content)
      out.flush
      out.close
    rescue 
      logger.fatal "could not write submission for user= #{user_id} file_name #{file_name}"
    end

  end

  def continue_running(x)
    true
  end


end
