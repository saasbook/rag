# Try to get the root of the current project
require 'pathname'
module CodeMetrics
  class StatsDirectories
    StatDirectory = Struct.new(:description, :path) do
      def to_a
        [description, path]
      end
      def inspect
        to_a.inspect
      end
      def directory?
        File.directory?(path)
      end
      def name(file_pattern)
        path.sub(/^\.\/(#{file_pattern}\/\w+)\/.*/, '\\1')
      end
      def self.from_list(list, path_prefix='')
        list.map do |description, path|
          new(description, [path_prefix,path].compact.join('/'))
        end.select(&:directory?)
      end
    end

    attr_reader :app_directories, :test_directories

    def initialize
      @root = path_prefix
      @app_directories = default_app_directories
      @test_directories = default_test_directories
    end

    def directories
      app_directories.map(&:to_a) | test_directories.map(&:to_a)
    end

    # What Rails expects
    def default_app_directories
      StatDirectory.from_list([
        %w(Controllers        app/controllers),
        %w(Helpers            app/helpers),
        %w(Models             app/models),
        %w(Mailers            app/mailers),
        %w(Javascripts        app/assets/javascripts),
        %w(Libraries          lib),
        %w(APIs               app/apis)
      ], @root)
    end

    def default_test_directories
      StatDirectory.from_list([
        %w(Controller\ tests  test/controllers),
        %w(Helper\ tests      test/helpers),
        %w(Model\ tests       test/models),
        %w(Mailer\ tests      test/mailers),
        %w(Integration\ tests test/integration),
        %w(Functional\ tests\ (old)  test/functional),
        %w(Unit\ tests \ (old)       test/unit)
      ], @root)
    end

    # @example add_directories('./spec/**/*_spec.rb', 'spec')
    #   will build dirs with the format of description, path:
    #   [ 'Acceptance specs', 'spec/acceptance' ]
    def add_directories(dir_pattern, file_pattern)
      build_directories(dir_pattern, file_pattern).each do |description, path|
        add_directory(description, path)
      end
      self
    end

    def add_test_directories(dir_pattern, file_pattern)
      build_directories(dir_pattern, file_pattern).each do |description, path|
        add_test_directory(description, path)
      end
      self
    end

    def add_directory(description,folder_path)
      folder_path = folder_path.to_s
      unless app_directories.any?{|stat_dir| stat_dir.path == folder_path}
        app_directories << StatDirectory.new(description, folder_path)
      end
      self
    end

    def add_test_directory(description,folder_path)
      folder_path = folder_path.to_s
      unless test_directories.any?{|stat_dir| stat_dir.path == folder_path}
        test_directories << StatDirectory.new(description, folder_path)
        CodeMetrics::Statistics::TEST_TYPES << description
      end
      self
    end

    # @example build_directories('./spec/**/*_spec.rb', 'spec')
    def build_directories(glob_pattern, file_pattern)
      dirs = collect_directories(glob_pattern, file_pattern)

      Hash[dirs.map { |path|
            [description(path.basename,file_pattern), path]
            }
          ]
    end
    # collects non empty directories and names the metric by the folder name
    # parent? or dirname? or basename?
    def collect_directories(glob_pattern, file_pattern='')
      Pathname.glob(glob_pattern).select{|f| f.basename.to_s.include?(file_pattern) }.map(&:dirname).uniq.map(&:realpath)
    end

    def description(path_basename,file_pattern)
      if path_basename.to_s == file_pattern
        "Uncategorized #{pluralize(file_pattern)}"
      else
       "#{titlecase(path_basename)} #{pluralize(file_pattern)}"
      end.strip
    end

    def titlecase(string)
      string = string.to_s
      "#{string[0..0].upcase}#{string[1..-1]}"
    end

    def pluralize(string)
      "#{string}s" unless string.to_s.empty?
    end

    def path_prefix
       (defined?(Rails) &&  Rails.root) || Pathname.pwd
    end
  end
end
