# http://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes
require 'logger'
module RagLogger
  def logger
    RagLogger.logger
  end

  def self.logger
    unless @logger_file
      Dir.mkdir('log/') unless File.directory?('log/')
      @logger_file ||= "log/rag-#{Process.pid}.log"
    end
    @logger ||= Logger.new(@logger_file, 0, 1024*1024)
  end
end
