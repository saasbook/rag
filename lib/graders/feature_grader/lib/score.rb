class Score
  attr_accessor :points, :max

  def initialize(points=0, max_points=0)
    @points = points
    @max    = max_points
  end

  def +(other)
    case other
    when Score
      Score.new(@points+other.points, @max+other.max)
    when Numeric
      Score.new(@points+other, @max+other)
    else
      raise ArgumentError
    end
  end

  def *(scalar)
    raise ArgumentError unless scalar.is_a? Numeric
    Score.new(@points*scalar, @max*scalar)
  end

  def normalize(max_points=nil)
    max_points ||= 1.0
    self * (max_points/@max)
  end

  def pass(n)
    n ||= 1
    @points += n
    @max += n
  end

  def fail(n)
    n ||= 1
    @max += n
  end

  def to_s
    "#{@points} / #{@max}"
  end
end

