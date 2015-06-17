require 'yaml'

module Adapter
  class Base
    include RagLogger
    include AutoGraderSubprocess
    attr_accessor :conf, :autograder_hash

    def initialize(config_hash)
      raise NotImplementedError 'abstract method'
    end

    def run
      raise NotImplementedError 'abstract method'
    end

  end
end
