
require_relative 'heroku_rspec_grader'
require 'open-uri'


class LocalServerGrader < HerokuRspecGrader
  class LocalServerGrader::ProcessUnkillableError < StandardError ; end
  class LocalServerGrader::RunProcessError < StandardError ; end

  attr_accessor :log

  def initialize(archive, grading_rules)
    super('', grading_rules)
    @archive = archive
    @host = '127.0.0.1' #TODO load config from yml file?
    @port = '3000'
    # super field do not change
    @heroku_uri = 'http://' + @host + ':' + @port
    @log = Logger.new(STDOUT)
    @log.level = Logger::WARN
    @log.info LocalServerGrader.to_s + ' init() uri: ' + @heroku_uri
  end


  def set_log_level(level)
    @log.level = level if @log.respond_to? :level=
  end

  def grade!
    Dir.mktmpdir('rails_intro_archive', '/tmp') do |tmpdir|
      kill_port_process!
      @log.info "extract #{@archive} to #{tmpdir}"
      run_process "tar -xvf #{@archive} -C /#{tmpdir}"

      pid = Open3.popen3('rails s', :chdir => tmpdir)[3].pid
      Process.detach pid
      @log.info "start rails PID: #{pid}"
      rails_up_timeout(20, 3)
      
      super
      kill_port_process! pid
    end
  end


  def run_process(cmd, dir='.', reraise=false)
    @p_out, @p_errs, @p_stat = Open3.capture3(cmd, :chdir => dir)

    unless @p_stat.success? and @p_errs == '' then
      pretty = "\n" + LocalServerGrader.to_s + ': Errors from command: ' + cmd +
        "\n" + @p_out +
        "\n" + @p_errs +
        "\n" + @p_stat.inspect
      @log.error pretty
      raise RunProcessError, pretty if reraise
    end
  end

  def kill_port_process!(pid=nil)   
    pid ||= find_port_process
    pid = pid.to_i
    escalating_kill(pid) if pid > 0 && process_running?(pid)
    if process_running?(pid)
      err_msg = "Process #{pid} cannot be killed."
      @log.error err_msg
      raise ProcessUnkillableError, err_msg
    end
  end

  def find_port_process
    #TODO brittle
    run_process "lsof -wni tcp:#{@port} | xargs echo | cut -d ' ' -f 11"
    pid = @p_out
  end

  def escalating_kill(pid)
    begin
      # dont need
      exit_status = Process.kill('INT', pid)
      exit_status = Process.kill('KILL', pid) unless exit_status == 1
      @log.info "kill #{pid} exit_status: #{exit_status}"
      return true if exit_status == 1
    rescue Errno::ESRCH => e
      @log.warn e.inspect
    rescue Exception => e
      @log.error e.inspect
    end
    false
  end

  def process_running?(pid, wait=1)
    sleep wait
    pid = pid.to_i
    # zero is the current process, dont kill it
    return false if pid <= 0
    begin
      if Process.getpgid(pid)
        @log.info "process #{pid} running"
        return true 
      end
      if Process.kill(0, pid) == 1
        @log.info "poke process #{pid}: found"
        return true 
      end
    rescue Errno::ESRCH
      @log.info 'Process not found for pid ' + pid.to_s
    # possible platform differences caught this way, untested
    rescue Errno::EPERM
      @log.error "Process #{pid} owner not the same as this process owner #{Process.uid}."
    end
    false
  end

  def rails_up_timeout(sec=20, polling=1)
    raise ArgumentError,
     "Polling interval must be greater than zero." if polling <= 0
    raise ArgumentError,
     "Polling interval must be less than or equal to timeout." if polling > sec
    begin
      to_status = timeout(sec) {
        sleep(polling) until app_loaded?
      }
    rescue Timeout::Error => e
      err_msg = "Rails timed out : #{sec} seconds. " + e.message
      @log.error err_msg
      @log.info e.backtrace.to_s
      raise e, err_msg, e.backtrace
    end
  end

  def app_loaded?
    begin
      uri = URI.parse @heroku_uri
      return true if OpenURI.open_uri uri
    # ECONNREFUSED happens when not fully started yet
    rescue Errno::ECONNREFUSED => e
      @log.info e.inspect
    rescue Exception => e
      @log.error e.inspect
    end
    false
  end


end
