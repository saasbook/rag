class RedCard
  VERSION = "1.1.0"

  class Version
    def initialize(version, candidate)
      @version_spec = version.to_str
      @version = convert @version_spec

      case candidate
      when Range
        @minimum_spec = candidate.begin.to_str
        @maximum_spec = candidate.end.to_str
        @exclusive = candidate.exclude_end?

        @minimum = convert @minimum_spec
        @maximum = convert @maximum_spec
      else
        @minimum = convert candidate.to_str
        @maximum = nil
        @exclusive = nil
      end
    end

    def valid?
      return false unless @version >= @minimum
      return true if @maximum.nil?

      if @exclusive
        return @version < @maximum
      else
        return @version <= @maximum
      end
    end

    def convert(string)
      major, minor, tiny, patch = string.split "."
      parts = [major, minor, tiny, patch].map { |x| x.to_i }
      ("1%03d%03d%03d%05d" % parts).to_i
    end
  end
end
