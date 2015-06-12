require_relative 'base'

module Adapter
  class Polling < Base
    def run
      connect
      while true
        poll
      end
    end

    def connect
      raise NotImplementedError, "abstract method"
    end

    def poll
      raise NotImplementedError, "abstract method"
    end
  end
end
