require 'tempfile'
require 'yaml'
require 'net/http'
require 'Base64'

require './lib/coursera_controller.rb'
require './lib/coursera_submission.rb'
require './lib/auto_grader.rb'

class CourseraClient
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
        puts assignment_part_sid
        if @controller.get_queue_length(assignment_part_sid) == 0
          puts "  deleting assignment part"
          to_delete << assignment_part_sid
          next
        end
        result = @controller.get_pending_submission(assignment_part_sid)
        next if result.nil?
        puts "  got submission"
        puts result['submission_metadata']

        raise "Can't handle encoding: #{result['submission_encoding']}" if result['submission_encoding'] != 'base64'
        submission = Base64.strict_decode64(result['submission'])
        #puts submission
        spec = load_spec(assignment_part_sid)
        grader_type = @autograders[assignment_part_sid][:type]

        # Original method
        #grade = run_autograder(submission, spec, grader_type)
        #score = grade.normalized_score
        #comments = grade.comments

        # FIXME: Run as subprocess
        score, comments = run_autograder_subprocess(submission, spec, grader_type)
        @controller.post_score(result['api_state'], score, comments)

        #puts "  scored #{score}: #{comments}" if score != 100
        puts "  scored #{score}: #{comments}"
      end

      @autograders.delete_if{|key,value| to_delete.include? key}
    end
  end

  def download_submissions(file)
    # Iterate through assignment parts until all queues are empty
    # Note, this process MUST complete in under 15 minutes or else the queues
    # will start repopulating. This method does NOT permanently remove 
    # submissions from the queue
    raise if file.nil?
    submissions = {}
    @autograders.each_key {|x| submissions[x] = []}

    @autograders.keys.each do |assignment_part_sid|
      while true
        if @controller.get_queue_length(assignment_part_sid) == 0
          puts "  deleting assignment part"
          break
        end
        result = @controller.get_pending_submission(assignment_part_sid)
        next if result.nil?
        puts "  got submission"
        submissions[assignment_part_sid] << result
      end
    end
    puts "Finishing"
    file.write(submissions.inspect)
    file.flush
  end

  private

  def load_spec(assignment_part_sid)
    raise "Assignment part #{assignment_part_sid} not found!" unless @autograders.include?(assignment_part_sid)
    autograder = @autograders[assignment_part_sid]
    return autograder[:uri] if autograder[:uri] !~ /^http/ # Assume that if uri doesn't start with http, then it is a local file path

    # If not in cache, download and add to cache
    if autograder[:cache].nil?
      spec_file = Tempfile.new('spec')
      response = Net::HTTP.get_response(URI(autograder[:uri]))
      if response.code !~ /2\d\d/
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
    raise "Failed to parse autograder output", str
  end

  # FIXME: This is a hack, remove later
  # Runs a separate process for grading
  def run_autograder_subprocess(submission, spec, grader_type)
    output = ''
    Tempfile.open(['test', '.rb']) do |file|
      file.write(submission)
      file.flush
      if grader_type == 'HerokuRspecGrader'
        output = `./grade_heroku #{submission} #{spec}`
      else
        output = `./grade #{file.path} #{spec}`
      end
      if $?.to_i != 0
        raise 'AutograderSubprocess error'
      end
    end

    score, comments = parse_grade(output)
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
end
