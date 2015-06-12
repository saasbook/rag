begin
  require 'xqueue' unless defined?(::XQueue)
rescue LoadError
  puts "xqueue is not installed. Please, do $ [sudo] gem install xqueue"
end

require_relative 'rag_logger'

module Main_Adapter
  module Adapters
    module XQueue
      extend self
      include RagLogger

      require 'net/https'
      require 'json'
      require "addressable/uri"

      # def to_html(string)
      #   ::RDiscount.new(string).to_html
      # end
      
      def looper
        conf = load_configurations(conf_name,config_path)
        @queue_uri = conf['queue_uri'] #xqueue_url
        @user_auth=conf['user_auth'].values
        @django_auth=conf['django_auth'].values
        @halt = conf['halt']
        @sleep_duration = conf['sleep_duration'].nil? ? 5*60 : conf['sleep_duration'] # in seconds
        @queue_name = conf['queue_name'] ####### need to add in config file -- "BerkeleyX-cs169x"

        xqueue = XQueueSubmission.new(.........)
        xqueue.authenticate(........)

        while true
          if xqueue.get_queue_length() == 0
            logger.info "sleeping for #{@sleep_duration} seconds"
            sleep @sleep_duration
            # need to reauthenticate? 
            next
          end
          submission = XQueueSubmission.get_submission(....)
          next if submission.nil?
          submission, autograder_type, spec = XQueueSubmission.a_method(....)
          yield submission, autograder_type, spec
        end
      end

      def send_grade_response(score, comments, student_info, submission_info)
        #converted = convert_to_JSON(score, comments)
        xqueue.postback_response(...)#converted, student_info, submission_info)
      end

      private
      def load_configurations(conf_name=nil, config_path='config/conf.yml') 
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
  end
end
