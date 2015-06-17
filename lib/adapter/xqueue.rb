require 'xqueue_ruby'

require_relative 'polling'

module Adapter
  class Xqueue < Polling
    def initialize(conf)
      super(conf)
      @xqueue_config = translate_file_conf_to_gem_conf(conf)
      # @halt = conf['halt']  # TODO: figure out what this is for
      @xqueue = ::XQueue.new(@xqueue_config)
    end

    def poll
      return if @xqueue.queue_length == 0
      submission = @xqueue.get_submission || return
      yield submission
      # {queue: xqueue, header: header, files: files, student_id: anonymous_student_id, submission_time: submission_time }
    end

    def get_submission
      @xqueue.get_submission
      # {queue: xqueue, header: header, files: files, student_id: anonymous_student_id, submission_time: submission_time }
    end

    def translate_file_conf_to_gem_conf(conf)
      {
        queue_uri: conf['queue_uri'],
        django_name: conf['django_auth']['username'],
        django_pass: conf['django_auth']['password'],
        user_name: conf['user_auth']['user_name'],
        user_pass: conf['user_auth']['user_pass'],
        queue_name: conf['queue_name'],
        # TODO: need to add in config file: "BerkeleyX-cs169x" (for queue_name)
      }
    end
  end
end
