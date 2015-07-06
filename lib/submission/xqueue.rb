require 'xqueue_ruby'
require_relative '../assignment/xqueue'
require_relative 'polling'

module Submission
  ENV['base_folder'] = 'submissions/'
  puts "ENV['base_folder'] set in module #{self} to #{ENV['base_folder']}"
  class Xqueue < Polling
    attr_reader :x_queue

    def initialize(config_hash)
      super(config_hash)
      @x_queue = ::XQueue.new(*create_xqueue_hash(config_hash))
    end

    def next_submission_with_assignment
      submission = @x_queue.get_submission
      return if submission.nil?
      # TODO: update XQueue gem to allow returning subclasses of ::XQueue::Submission
      class << submission; attr_accessor :assignment; end
      submission.assignment = Assignment::Xqueue.new(submission)
      submission.unzip! ENV['base_folder']
      submission
    end

    def submit_response(graded_submission)
      graded_submission.correct = graded_submission.score != 0
      graded_submission.post_back
    end

    def create_xqueue_hash(config_hash)
      [
        config_hash['django_auth']['username'],  # django_name
        config_hash['django_auth']['password'],  # django_pass
        config_hash['user_auth']['user_name'],   # user_name
        config_hash['user_auth']['user_pass'],   # user_pass
        config_hash['queue_name']                # queue_name
      ]
    end
  end
end
