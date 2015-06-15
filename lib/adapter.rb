module Adapter
  # not too sure if this is valid..... 
  def default(str="XqueueAdapter")
    return eval("Adapter::"+str)
  end
end
