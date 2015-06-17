require 'yaml'

module Adapter
  class Base
    include RagLogger
    include AutoGraderSubprocess
    attr_accessor :conf, :autograder_hash

    def initialize(config_hash)
      # raise NotImplementedError.new'abstract method'
    end

    def run
      # raise NotImplementedError.new 'abstract method'
    end

  end
end
