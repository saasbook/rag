class RedCard
  class Engine
    def initialize(engine, candidate)
      @engine = engine.to_s
      @candidate = candidate.to_s
    end

    def valid?
      case @engine
      when "rbx"
        @candidate == "rbx" or @candidate == "rubinius"
      else
        @candidate == @engine
      end
    end
  end
end
