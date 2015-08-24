class Filter
  attr_accessor :limit, :error, :warn

  def initialize(limit = -1, error = 11, warn = 8)
    @limit = limit
    @error = error
    @warn = warn
  end

  def ignore?(count)
    count < @limit
  end

  def warn?(count)
    count >= @warn
  end

  def error?(count)
    count >= @error
  end

end
