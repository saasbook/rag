require 'xqueue_ruby'

require_relative 'polling'
require_relative 'x_queue_assignment'

module Adapter
  class Xqueue < Polling

    attr_reader :x_queue

    def initialize(config_hash)
      super(config_hash)
      @xqueue_config = create_xqueue_hash(config_hash)
      # @halt = conf['halt']  # TODO: figure out what this is for
      @x_queue = ::XQueue.new(*@xqueue_config.values)
    end

    def poll
      return if @xqueue.queue_length == 0
      submission = @xqueue.get_submission || return
      yield submission
      # {queue: xqueue, header: header, files: files, student_id: anonymous_student_id, submission_time: submission_time }
    end

    def get_submission_and_assignment
      # @x_queues.each do |x_queue| 
      submission = @x_queue.get_submission
      if submission 
        return submission, XQueueAssignment.new(submission)
      end
      # end
     return nil, nil
    end

    def submit_response(graded_submission)
      graded.submission.correct = !!graded_submission.score
      graded_submission.post_back
    end

    def create_xqueue_hash(config_hash)
      #this hash becomes order specific the way we use this. fix
      {
        django_name: config_hash['django_auth']['username'],
        django_pass: config_hash['django_auth']['password'],
        user_name: config_hash['user_auth']['user_name'],
        user_pass: config_hash['user_auth']['user_pass'],
        queue_name: config_hash['queue_name']
      }
    end


  end
end
