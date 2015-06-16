require_relative 'adapter/xqueue'

module Adapter
  ALL_BY_NAME = {
    xqueue: Xqueue
  }

  DEFAULT_NAME = :xqueue

  # not too sure if this is valid..... 
  def get(name = DEFAULT_NAME)
    ALL[name]
  end
end
