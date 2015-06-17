require_relative 'adapter/xqueue'

module Adapter
  ALL_BY_NAME = {
    xqueue: Xqueue
  }

  DEFAULT_NAME = :xqueue

  
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

  # not too sure if this is valid..... 
  def get(name = DEFAULT_NAME)
    ALL[name]
  end
end
