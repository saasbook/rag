require 'tempfile'

# class String
#   include Term::ANSIColor
# end

class Hash
  # Returns a new +Hash+ containing +to_s+ed keys and values from this +Hash+.

  def envify
    h = {}
    self.each_pair { |k,v| h[k.to_s] = v.to_s }
    return h
  end
end

class TempArchiveFile
  attr_reader :path

  def initialize(original_filename)
    @tempfile = Tempfile.new ['submission', '.tar.gz']
    @path = nil
    File.open(original_filename) do |o|
      FileUtils.copy_stream o, @tempfile
    end

    @path = File.join(File.dirname(@tempfile.path), File.basename(@tempfile.path, '.tar.gz'))
    FileUtils.mkdir_p @path
    `tar -xzf #{@tempfile.path} -C #{@path.inspect}`
    result = $?.to_i
    raise(ScriptError, "untar failed (submission not in .tar.gz format?)") unless result == 0
    return @path
  end

  def destroy
    @tempfile.close
    @tempfile.unlink
    @tempfile = nil
    if @path
      FileUtils.rm_rf @path
      @path = nil
    end
  end
end

class SourcedTempfile < Tempfile
  def initialize(*args)
    source_path = args.shift
    super(*args)
    File.open source_path {|io| FileUtils.copy_stream io, self}
  end
end

