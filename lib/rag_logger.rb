require 'logger'

module RagLogger

  #Create a singleton logger used across all rag classes. Write to a specified log file, if already exists, create a new file w/ timestamp in file name
  def self.configure_logger(log_to_file, level)
    if log_to_file
      @@logger = Logger.new(File.open("logs/log-#{Time.now.to_s}", 'w'))
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