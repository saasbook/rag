require 'logger'

module RagLogger

  #Create a singleton logger used across all rag classes. Write to a specified log file, if already exists, create a new file w/ timestamp in file name
  def self.configure_logger(output_file, level)
    log_file = File.exist?(output_file) ? File.open(output_file + Time.now.to_s, 'w') : File.open(output_file, 'w')
    @@logger = Logger.new(log_file)
    @@logger.level = level
  end

  #If not configured, set logger to be stdout
  def logger
    @@logger ||= Logger.new(STDOUT)
  end
end