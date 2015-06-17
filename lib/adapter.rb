require 'yaml'

module Adapter
  DEFAULT_NAME = :xqueue

  ADAPTER_NOT_FOUND = "Adapter not found: %s"
  CONF_FILE_NOT_FOUND = <<-EOS.undent
    Conf file not found: %s
    Please copy conf.yml.example into %s and configure the parameters.
  EOS
  CONF_KEY_NOT_FOUND = <<-EOS.undent
    Conf key not found: %s
    In conf file: %s
  EOS

  # Returns hash of assignment_part_ids to hashes containing uri and grader type
  # i.e. { "assign-1-part-1" => {:uri => 'solutions/part1_spec.rb', :type => 'RspecGrader' } }
  def initialize_autograders(filename)
    # TODO: Verify file format
    yml = YAML::load(File.open(filename, 'r'))
    yml.each_pair do |id, obj|
      # Convert keys from string to sym
      yml[id] = obj.inject({}){|memo, (k,v)| memo[k.to_sym] = v; memo}
    end
  end

  def new(path, key)
    conf = load_conf(path, key)
    get(conf['adapter']).new(conf)
  end

  private

  def load_conf(path, key)
    raise CONF_FILE_NOT_FOUND % path, path unless File.file?(path)
    confs = YAML.load_file(path)
    confs[key] || (raise CONF_KEY_NOT_FOUND % key, path)
  end

  def get(name = DEFAULT_NAME)
    case name.lower.to_sym
    when :xqueue
      require_relative 'adapter/xqueue'
      Xqueue
    else
      raise ADAPTER_NOT_FOUND % name.inspect
    end
  end
end
