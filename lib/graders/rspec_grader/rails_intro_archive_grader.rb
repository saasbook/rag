require_relative 'heroku_rspec_grader'

class RailsIntroArchiveGrader < HerokuRspecGrader
  def initialize(archive, grading_rules)
    super('', grading_rules)
    #TODO make it other than port 3000
    @heroku_uri = 'http://localhost:3000'
    @archive = archive
  end

  def run_process(cmd, dir)
    #env = {
    #    'RAILS_ROOT' => @temp,
    #    'RAILS_ENV' => 'test',
    #    'BUNDLE_GEMFILE' => 'Gemfile'
    #}
      @output, @errors, @status = Open3.capture3(
          cmd, :chdir => dir
      #env, cmd, :chdir => dir
      )
      puts (cmd +
          @output +
          @errors +
          @status.to_s) unless @status.success? and @test_errors.empty?

    # Gets Net:HTTP:Persistent error
    #Open3.popen3(env, cmd) do |stdin, stdout, stderr, wait_thr|
    #  exitstatus = wait_thr.value.exitstatus
    #  out = stdout.read
    #  err = stderr.read
    #  if exitstatus != 0
    #    raise out + err
    #  end
    #end
  end

  def app_loaded?
    begin
      require 'net/http'
      uri = URI.parse("http://127.0.0.1:3000/movies/")
      response = Net::HTTP.get_response(uri)
      if response and response.code
        return true if response.respond_to?(:code) && response.code == '200'
      end
    rescue Errno::ECONNREFUSED
      return false
    end
    #return true if `$RAILS_ENV`
    false
  end

  def wait_for_app_max(sec, polling=1)
    to_status = timeout(sec) {
      sleep(polling) until app_loaded?
    }
  end

  def grade!
    ENV['HEROKU_URI'] = @heroku_uri

    #start_time = Time.now()
    Dir.mktmpdir('rails_intro_archive', '/tmp') do |tmpdir|

      @temp = tmpdir

      untar_cmd = "tar -xvf #{@archive} -C /#{@temp}"
      `#{untar_cmd}`

      pid = Process.fork do
        run_process('rails s', @temp)
      end
      #Process.detach(pid)

      # Gets Net::HTTP::Persistent::Error on local if no timeout, increasing for travis
      wait_for_app_max(30)

      super

      # prev pid no good, get now
      pid = `pgrep -f "ruby script/rails s"`
      Process.kill('INT', pid.to_i)
      Process.kill('KILL', pid.to_i)

    end


  end


end

