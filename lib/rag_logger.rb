# http://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes
# a singleton logger shared between all instances of logger
require 'logger'

class RagLogger < Logger
  @@logger
  def initialize(logdev, shift_age = 0, shift_size = 1048576)
    @@logger || @@logger = super
  end
  
end