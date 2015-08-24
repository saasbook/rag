module CodeMetrics

  class Profiler
    Error = Class.new(StandardError)

    attr_reader :path, :mode
    def initialize(path, mode=nil)
      assert_ruby_file_exists(path)
      @path, @mode = path, mode
      Gem.refresh
      # H/T https://github.com/pry/pry/blob/b02d0a4863/lib/pry/plugins.rb#L72
      Gem::Specification.respond_to?(:each) ? Gem::Specification.all : Gem.source_index
      require 'benchmark'
    end

    def profile_requires
      GC.start
      before_rss = `ps -o rss= -p #{Process.pid}`.to_i

      if mode
        require 'ruby-prof'
        RubyProf.measure_mode = RubyProf.const_get(mode.upcase)
        RubyProf.start
      else
        Object.instance_eval { include RequireProfiler }
      end

      elapsed = Benchmark.realtime { require path }
      results = RubyProf.stop if mode

      GC.start
      after_rss = `ps -o rss= -p #{Process.pid}`.to_i

      if mode
        if printer = ARGV.shift
          RubyProf.const_get("#{printer.to_s.classify}Printer").new(results).print($stdout)
        elsif RubyProf.const_defined?(:CallStackPrinter)
          File.open("#{File.basename(path, '.rb')}.#{mode}.html", 'w') do |out|
            RubyProf::CallStackPrinter.new(results).print(out)
          end
        else
          File.open("#{File.basename(path, '.rb')}.#{mode}.callgrind", 'w') do |out|
            RubyProf::CallTreePrinter.new(results).print(out)
          end
        end
      end

      RequireProfiler.stats.each do |file, depth, sec|
        if sec
          puts "%8.1f ms  %s%s" % [sec * 1000, ' ' * depth, file]
        else
          puts "#{' ' * (13 + depth)}#{file}"
        end
      end
      puts "%8.1f ms  %d KB RSS" % [elapsed * 1000, after_rss - before_rss]
    end

    private

    def assert_ruby_file_exists(path)
      raise Error.new("No such file") unless File.exists?(path)
      ruby_extension = path[/\.rb\Z/]
      ruby_executable = File.open(path, 'rb').readline[/\A#!.*ruby/]
      raise Error.new("Not a ruby file") unless ruby_extension or ruby_executable
    end

  end

  module RequireProfiler
    private
    def require(file, *args) RequireProfiler.profile(file) { super } end
    def load(file, *args) RequireProfiler.profile(file) { super } end

    @depth, @stats = 0, []
    class << self
      attr_accessor :depth
      attr_accessor :stats

      def profile(file)
        stats << [file, depth]
        self.depth += 1
        result = nil
        elapsed = Benchmark.realtime { result = yield }
        self.depth -= 1
        stats.pop if stats.last.first == file
        stats << [file, depth, elapsed] if result
        result
      end
    end
  end
end
if $0 == __FILE__
  path = File.expand_path(ARGV.shift)
  mode = ARGV.shift
  CodeMetrics::Profiler.new(path, mode).profile_requires
end
