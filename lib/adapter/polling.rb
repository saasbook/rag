require_relative 'base'

module Adapter
  class Polling < Base
    attr_accessor :sleep_duration

    def initialize(path, name)
      super(path, name)
      @sleep_duration = conf['sleep_duration'] || 5 * 60
    end

    def run(&block)
      connect
      while true
        next_sleep_duration = poll(&block) || sleep_duration
        next_sleep_duration = 0 if next_sleep_duration == true
        sleep next_sleep_duration
      end
    end

    def connect
    end

    def poll
      raise NotImplementedError, "abstract method"
    end
  end
end
