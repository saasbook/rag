require 'yaml'

module Adapter
  class Base
    attr_accessor :conf, :autograder

    def run
      raise NotImplementedError, "abstract method"
    end
  end
end
