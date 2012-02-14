require 'tempfile'
require 'yaml'
require 'net/http'
require 'Base64'

require './lib/class_x_controller.rb'
require './lib/class_x_submission.rb'
require './lib/auto_grader.rb'

class ClassXClient
  class ClassXClient::UnknownAssignmentPart < StandardError ; end
  class ClassXClient::SpecNotFound < StandardError ; end

  # Requires a file called 'autograders.yml' to exist in the current working 
  # directory and it must represent a hash from assignment_part_sid's to
  # spec URIs

  def initialize(endpoint, api_key, autograders_yml)
    @endpoint = endpoint
    @api_key = api_key
    #@assignment_id = assignment_id
    #@queue_id = queue_id || assignment_id
    @controller = ClassXController.new(endpoint, api_key)

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
        #grade = run_autograder(submission, spec)
        #score = grade.normalized_score
        #comments = grade.comments
        Tempfile.open(['test', '.rb']) do |file|
          file.write(submission)
          file.flush
          score, comments = ghetto_run_autograder(file.path, spec)
          @controller.post_score(result['api_state'], score, comments)
          #puts "  scored #{score}: #{comments}" if score != 100
          puts "  scored #{score}: #{comments}"
        end
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
    if autograder[:cache].nil?
      spec_file = Tempfile.new('spec')
      response = Net::HTTP.get_response(URI(autograder[:uri]))
      if response.code !~ /2\d\d/
        raise ClassXClient::SpecNotFound, "Could not load the spec at #{autograder[:uri]}"
      end
      spec_file.write(response.body)
      spec_file.flush
      autograder[:cache] = spec_file
    end
    autograder[:cache].path
  end

  # Ghetto fix, remove later
  def ghetto_run_autograder(submission, spec)
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

    # Normal stuff
    output = `./grade #{submission} #{spec}`

    #HEROKU stuff
    #uri = File.open(submission, 'r'){|x| x.read}
    #uri.gsub!(/herokuapps/, 'herokuapp')
    #puts uri
    ## This is a ghetto thing for the rottenpotatoes app
    #output = `HEROKU_URI="#{uri}" ./grade dummy_file.rb #{spec}`

    score, comments = parse_grade(output)
    comments.gsub!(spec, 'spec.rb')
    [score, comments]
  end


  #def run_autograder(submission, spec)
  #  g = AutoGrader.create('1', 'WeightedRspecGrader', submission, :spec => spec)
  #  g.grade!
  #  g
  #end

  def init_autograders(filename)
    # TODO: Verify file format
    YAML::load(File.open(filename, 'r')).inject({}) do |result,pair|
      id, uri = pair
      result[id] = {uri: uri, cache: nil}
      result
    end
  end
end
