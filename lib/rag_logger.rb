require 'logger'

module RagLogger
  def self.configure_logger(output_file)
    @@logger = Logger.new(File.open(output_file, 'w'))
  end
  def logger
    @@logger ||= Logger.new(STDOUT)
  end
end