require 'yaml'

module Adapter

  # Returns hash of assignment_part_ids to hashes containing uri and grader type
  # i.e. { "assign-1-part-1" => {:uri => 'solutions/part1_spec.rb', :type => 'RspecGrader' } }
  def initialize_autograders(filename)
    # TODO: Verify file format
    yml = YAML::load(File.open(filename, 'r'))
    yml.each_pair do |id, obj|
      # Convert keys from string to sym
      yml[id] = obj.inject({}){|memo, (k,v)| memo[k.to_sym] = v; memo}
    end
          autograder = initialize_autograders(conf['autograders_yml'])
  end

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

    def run
      raise NotImplementedError, "abstract method"
    end
  end
end
