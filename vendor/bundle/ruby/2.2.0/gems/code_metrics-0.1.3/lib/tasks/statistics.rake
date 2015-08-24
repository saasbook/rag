begin
  require 'rake'
  namespace :code_metrics do

    desc "Report code statistics (KLOCs, etc) from the application"
    task :stats do
      require 'code_metrics/statistics'
      STATS_DIRECTORIES = CodeMetrics::StatsDirectories.new.directories
      CodeMetrics::Statistics.new(*STATS_DIRECTORIES).to_s
    end

    desc "Report LOC for each file, and a total LOC for the list of files. \bUsage rake code_metrics:line_statistics['lib/**/*.rb']"
    task :line_statistics, :file_pattern do |t, args|
      file_pattern = args[:file_pattern].to_s
      raise "No file pattern entered, e.g. :line_statistics['lib/**/*.rb']" if file_pattern.size == 0

      require 'code_metrics/line_statistics'
      files = FileList[file_pattern]
      CodeMetrics::LineStatistics.new(files).print_loc
    end

  end
rescue LoadError
  STDERR.puts "Cannot load rake code_metrics:stats task, rake not available"
end
