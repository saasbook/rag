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
    #@output, @errors, @status = Open3.capture3(
    #    env, cli_string, :chdir => dir
    #)
    #puts (cli_string +
    #    @output +
    #    @errors +
    #    @status.to_s) unless @status.success? #and @test_errors.empty?

    Open3.popen3(env, cmd) do |stdin, stdout, stderr, wait_thr|
      exitstatus = wait_thr.value.exitstatus
      out = stdout.read
      err = stderr.read
      if exitstatus != 0
        raise out + err
      end
    end
  end

  def grade!
    ENV['HEROKU_URI'] = @heroku_uri
    begin
      start_time = Time.now()
      Dir.mktmpdir('rails_intro_archive', '/tmp') do |tmpdir|

        @temp = tmpdir

        untar_cmd = "tar -xvf #{@archive} -C /#{@temp}"
        `#{untar_cmd}`

        pid = Process.fork {
          run_process('system rails s', @temp)
        }
        Process.detach(pid)

        #TODO arbitrary, use a timeout?
        # Gets Net::HTTP::Persistent::Error on local if no timeout, increasing for travis
        sleep 15

        super
        #kill -2 #{@pid}`
        #if `lsof -wni tcp:3000`
        #  `kill -9 #{@pid}`
        #end
      end

      #puts "Total score: #{@raw_score} / #{@raw_max}"
      puts "Completed in #{Time.now-start_time} seconds."
        #  dump_output
    ensure
      #@temp.destroy if @temp
    end
  end
end
