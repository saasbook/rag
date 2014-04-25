
require_relative 'heroku_rspec_grader'
require 'open-uri'

class RailsIntroArchiveGrader < HerokuRspecGrader
  class RailsIntroArchiveGrader::ProcessUnkillableError < StandardError ; end


  def initialize(archive, grading_rules)
    super('', grading_rules)
    @archive = archive
    @host = '127.0.0.1' #TODO load config from yml file?
    @port = '3000'

    # super field do not change
    @heroku_uri = 'http://' + @host + ':' + @port

  end


  def grade!
    Dir.mktmpdir('rails_intro_archive', '/tmp') do |tmpdir|
      kill_port_process!
      run_process "tar -xvf #{@archive} -C /#{tmpdir}"

      pid = Open3.popen3('rails s', :chdir => tmpdir)[3].pid
      Process.detach pid
      rails_up_timeout

      super

      kill_port_process! pid
    end
  end


  def run_process(cmd, dir='.')
    @p_out, @p_errs, @p_stat = Open3.capture3(cmd, :chdir => dir)

    unless @p_stat.success? and @p_errs == '' then
      pretty = "\n" + RailsIntroArchiveGrader.to_s + ': Errors from command: ' + cmd +
        "\n" + @p_out +
        "\n" + @p_errs +
        "\n" + @p_stat.inspect
      log pretty
      # raise RunProcessError, pretty
    end
  end

  def kill_port_process!(pid=nil)   
    pid ||= find_port_process
    pid = pid.to_i
    if pid > 0 && process_running?(pid)
      # SIGINT is rails trapped signal, equivalent to ctrl+c
      escalating_kill(pid)
      #sleep 3
      if process_running?(pid)
        err_msg = "Process #{pid} cannot be killed."
        log err_msg
        raise ProcessUnkillableError, err_msg
      end
    end
  end

  def find_port_process
    run_process "lsof -wni tcp:#{@port} | xargs echo | cut -d ' ' -f 11"
    pid = @p_out
  end

  def escalating_kill(pid)
    begin
      exit_status = Process.kill('INT', pid)
      exit_status = Process.kill('KILL', pid) unless exit_status == 1
      log "kill #{pid} exit_status: #{exit_status}"
      return true if exit_status == 1
    rescue Errno::ESRCH => e
      log e.inspect
    rescue => e
      log e.inspect
    end 
  end

  # delay if you have just changed the state of the process
  def process_running?(pid, wait=1)
    sleep wait
    pid = pid.to_i
    # zero represents the current process, dont kill it
    return false if pid <= 0
    begin
      if Process.getpgid(pid)
        log "process #{pid} running"
        return true 
      end
      if Process.kill(0, pid) == 1
        log "poke process #{pid}: found"
        return true 
      end
    rescue Errno::ESRCH
      log 'Process not found for pid ' + pid.to_s
    # possible platform differences caught this way, untested
    rescue Errno::EPERM
      log "Process #{pid} owner not the same as this process owner #{Process.uid}."
    end
    false
  end

  def rails_up_timeout(sec=20, polling=1)
    raise ArgumentError,
     "Polling interval must be greater than zero." if polling <= 0
    raise ArgumentError,
     "Polling interval must be greater than timeout" if polling > sec
    begin
      to_status = timeout(sec) {
        sleep(polling) until app_loaded?
      }
    rescue Timeout::Error => e
      err_msg = "Rails took too long to start: #{sec} seconds. Aborting. " + e.message
      log err_msg
      raise e, err_msg, e.backtrace
    end
  end

  def app_loaded?
    begin
      uri = URI.parse @heroku_uri
      return true if OpenURI.open_uri uri
    rescue Errno::ECONNREFUSED => e#The normal error if not fully started yet
      log e.inspect
      return false
    rescue => e
      log e.inspect
      return false
    end

    false
  end

  #TODO
  def log(*args)
    puts args
    # curl lib the logs to a logging service?
    # @log = Logger.new(STDOUT)
    # @log.level = Logger::WARN
  end

end
