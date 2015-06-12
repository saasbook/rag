require 'xqueue'
require_relative 'polling'

module Adapter
  class Xqueue < Polling
    def initialize(path, name)
      super(path, name)
      @xqueue_config = {
        queue_uri: conf['queue_uri'],
        django_name: conf['django_auth']['username']
        django_pass: conf['django_auth']['password']
        user_name: conf['user_auth']['user_name']
        user_pass: conf['user_auth']['user_pass']
        queue_name: conf['queue_name']
        # TODO need to add in config file: "BerkeleyX-cs169x"
      }
      @halt = conf['halt']
    end

    def connect
      @xqueue = XQueue.new(@xqueue_config)
    end

    def poll
      return if xqueue.queue_length == 0
      submission = xqueue.get_submission || return
      yield submission
      # {queue: xqueue, header: header, files: files, student_id: anonymous_student_id, submission_time: submission_time }
    end
  end
end
