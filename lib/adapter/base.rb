module Adapter
  class Base
    def initialize
    end

    def run
      raise NotImplementedError, "abstract method"
    end
  end
end
