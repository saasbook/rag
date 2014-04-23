require_relative 'heroku_rspec_grader'
require 'open-uri'

class RailsIntroArchiveGrader < HerokuRspecGrader

  def initialize(archive, grading_rules)
    super('', grading_rules)
    @archive = archive
    @host = '127.0.0.1' #TODO load config from yml file?
    @port = '3000' #TODO make it other than port 3000
    # super field
    @heroku_uri = 'http://' + @host + ':' + @port
  end

  def grade!
    kill_port_process!

    #TODO log it, log everything
    #TODO grader name sux

    Dir.mktmpdir('rails_intro_archive', '/tmp') do |tmpdir|
      @temp = tmpdir

      run_process("tar -xvf #{@archive} -C /#{@temp}", '.')

      #TODO should it be forking here?
      pid = Open3.popen3('rails s', :chdir => tmpdir)[3].pid
      Process.detach(pid)

      # wait for rails to start
      rails_up_timeout(30)

      super

      if pid > 0 and process_running?(pid)
        Process.kill('KILL', pid) unless Process.kill('INT', pid) == 1
      end
    end
  end

  def run_process(cmd, dir)
      @p_out, @p_errs, @p_stat = Open3.capture3(
          cmd, :chdir => dir
      )
      #TODO format output
      puts (cmd +
          @p_out +
          @p_errs +
          @p_stat.to_s) unless @p_stat.success? and @p_errs == ''
  end

  def process_running?(pid)
    begin
      return true if Process.getpgid(pid) != nil
      return true if Process.kill(0, pid) == 1
    rescue Errno::ESRCH
      puts 'Process not found for pid ' + pid.to_s
    rescue Errno::EPERM
      puts "Process #{pid} owner not the same as this process owner #{Process.uid}."
    end
    false
  end

  def kill_port_process!
    pid = `lsof -wni tcp:3000 | xargs echo | cut -d ' ' -f 11`.to_i
    #rails_pid = `pgrep -f "ruby script/rails s"`.to_i
    ##TODO log alert if these two numbers differ
    if pid > 0 && process_running?(pid)
      exit = Process.kill('INT', pid)
      Process.kill('KILL', pid) if exit != 1
      #TODO raise 'process can't be killed' unless stopped
    end
  end

  #TODO make timeout bulletproof
  def rails_up_timeout(sec, polling=1)
    #begin
    to_status = timeout(sec) {
      sleep(polling) until app_loaded?
    }
    #rescue Timeout::Error
    #end
  end

  def app_loaded?
    begin
      uri = URI.parse(@heroku_uri)
      return true if OpenURI.open_uri(uri)
    rescue Errno::ECONNREFUSED #The normal error if not fully started yet
      return false
    rescue => e
      #log e.inspect
      return false
    end
    false
  end

end

