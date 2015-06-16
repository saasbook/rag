require 'yaml'

module Adapter
  class Base
    attr_accessor :conf
    attr_accessor :autograder

    def initialize(path, name)
      unless File.file?(path)
        raise "Please copy conf.yml.example into conf.yml and configure the parameters"
      end
      confs = YAML.load_file(path)
      conf = confs[name] || raise "Couldn't load configuration #{conf_name}"
    end

    def run(&block)
      raise NotImplementedError, "abstract method"
    end
  end
end
