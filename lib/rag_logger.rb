require 'logger'

require 'fileutils'


module RagLogger

  #Create a singleton logger used across all rag classes. Write to a specified log file, if already exists, create a new file w/ timestamp in file name
  def self.configure_logger(log_to_file, level)
    if log_to_file
      FileUtils.mkdir_p('logs') unless File.directory?('logs')
      log_file = File.open('logs/log' + Time.now.strftime('%Y-%m-%d-%H:%M:%S') + '.txt', 'w')
      @@logger = Logger.new(log_file)
    else
      @@logger = Logger.new(STDOUT)
    end
    @@logger.level = level
  end

  #If not configured, set logger to be stdout
  def logger
    @@logger ||= Logger.new(STDOUT)
  end
end