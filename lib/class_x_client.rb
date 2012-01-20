require 'tempfile'
require 'yaml'
require 'net/http'

require './lib/class_x_controller.rb'
require './lib/class_x_submission.rb'
require './lib/auto_grader.rb'

class ClassXClient
  def initialize(endpoint, api_key, queue_id)
    @endpoint = endpoint
    @api_key = api_key
    @queue_id = queue_id
    @controller = ClassXController.new(endpoint, api_key)

    # Load configuration file for assignment_id->spec map
    @autograders = init_autograders
  end

  def run
    while @controller.get_queue_length(@queue_id) > 0
      result = @controller.get_pending_submission(@queue_id)
      next if result.nil?

      raise "Can't handle encoding: #{result['submission_encoding']}" if result['submission_encoding'] != 'base64'
      submission = ClassXSubmission.load_from_base64(result['submission'])
      spec = load_spec(submission.assignment_part_sid)
      grade = run_autograder(submission.submission, spec)
      server.post_score(submission['api_state'], grade.score, grade.comments)
    end
  end

  private

  def load_spec(assignment_part_sid)
    raise "Assignment part #{assignment_part_sid} not found!" unless @autograders.include?(assignment_part_sid)
    autograder = @autograders[assignment_part_sid]
    if autograder[:cache].nil?
      spec_file = Tempfile.new('spec')
      spec_file.write(Net::HTTP.get(autograder[:uri]))
      spec_file.flush
      autograder[:cache] = spec_file
    end
    autograder[:cache].path
  end

  def run_autograder(submission, spec)
    g = AutoGrader.create('1', 'RspecGrader', submission, :spec => spec)
    g.grade!
    g
  end

  def init_autograders
    YAML::load(File.open('autograders.yml')).inject({}) do |result,pair|
      id, uri = pair
      result[id] = {uri: uri, cache: nil}
    end
  end
end
