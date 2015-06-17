require 'xqueue_ruby'

require_relative 'polling'

module Adapter
  class Xqueue < Polling

    attr_reader :x_queue

    def initialize(config_hash)
      super(config_hash)
      @xqueue_config = create_xqueue_hash(config_hash)
      # @halt = conf['halt']  # TODO: figure out what this is for
      @x_queue = ::XQueue.new(@xqueue_config)
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
      nil, nil
    end

    def submit_response(graded_submission)
      graded_submission.post_back
    end

    def create_xqueue_hash(config_hash)
      {
        queue_name: conf['queue_name'],
        django_name: conf['django_auth']['username'],
        django_pass: conf['django_auth']['password'],
        user_name: conf['user_auth']['user_name'],
        user_pass: conf['user_auth']['user_pass']
      }
    end

  end
end
