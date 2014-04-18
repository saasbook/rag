require_relative 'heroku_rspec_grader'

class RailsIntroArchiveGrader < HerokuRspecGrader
  def initialize(archive, grading_rules)
    super('', grading_rules)
    #TODO make it other than port 3000
    @heroku_uri = 'http://localhost:3000'
    @archive = archive
  end

  def run_process(cmd, dir)
    env = {
        'RAILS_ROOT' => @temp,
        'RAILS_ENV' => 'test',
        'BUNDLE_GEMFILE' => 'Gemfile'
    }
      @output, @errors, @status = Open3.capture3(
          env, cmd, :chdir => dir
      )
      puts (cmd +
          @output +
          @errors +
          @status.to_s) #unless @status.success? #and @test_errors.empty?

    #Open3.popen3(env, cmd) do |stdin, stdout, stderr, wait_thr|
    #  exitstatus = wait_thr.value.exitstatus
    #  out = stdout.read
    #  err = stderr.read
    #  if exitstatus != 0
    #    raise out + err
    #  end
    #end
  end

  def grade!
    ENV['HEROKU_URI'] = @heroku_uri

    #start_time = Time.now()
    Dir.mktmpdir('rails_intro_archive', '/tmp') do |tmpdir|

      @temp = tmpdir

      untar_cmd = "tar -xvf #{@archive} -C /#{@temp}"
      `#{untar_cmd}`

      @pid = Process.fork do
        run_process('xterm -e rails s', @temp)
        #run_process('rails s', @temp)
      end
      #puts "PID == ", @pid
      Process.detach(@pid)

      #TODO arbitrary, use a timeout?
      # Gets Net::HTTP::Persistent::Error on local if no timeout, increasing for travis
      sleep 10

      super

      `pkill -f "xterm -e rails s"`


    end


  end


end

