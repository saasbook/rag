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
    when Integer
      Score.new(@points+other, @max+other)
    else
      raise ArgumentError
    end
  end

  def pass()
    @points += 1
    @max += 1
  end

  def fail()
    @max += 1
  end

  def to_s
    "#{@points} / #{@max}"
  end
end

