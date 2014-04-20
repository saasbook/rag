require_relative 'heroku_rspec_grader'

class RailsIntroArchiveGrader < HerokuRspecGrader
  def initialize(archive, grading_rules)
    super('', grading_rules)
    @archive = archive
    host = '127.0.0.1' #TODO load config from yml file?
    port = '3000' #TODO make it other than port 3000
    # TODO why can't change name of this variable? super?
    @heroku_uri = 'http://' + host + ':' + port
  end

  def grade!
    ENV['HEROKU_URI'] = @heroku_uri
    #TODO kill anything on our port
    #TODO log it, log everything
    #TODO grader name
    Dir.mktmpdir('rails_intro_archive', '/tmp') do |tmpdir|
      @temp = tmpdir
      #TODO run_process on it?
      untar_cmd = "tar -xvf #{@archive} -C /#{@temp}"
      `#{untar_cmd}`
      #TODO should it be forking here
      pid = Process.fork do
        run_process('rails s', @temp)
      end
      # wait for rails to start
      rails_up_timeout(30)

      super
      #TODO run_process on it?
      pid = `pgrep -f "ruby script/rails s"`
      #TODO repetitive
      Process.kill('INT', pid.to_i)
      Process.kill('KILL', pid.to_i)
    end
  end

  #TODO re-investigate open3 per hw4_grader
  def run_process(cmd, dir)
      @output, @errors, @status = Open3.capture3(
          cmd, :chdir => dir
      )
      #TODO format output
      puts (cmd +
          @output +
          @errors +
          @status.to_s) unless @status.success? and @errors == ''
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

  #TODO prefer mechanize?
  def app_loaded?
    #return true => test
    begin
      #uri = URI.parse("") => test
      #uri = URI.parse("#{@heroku_uri}/steez") => test causes timeout unless rescue
      uri = URI.parse("#{@heroku_uri}")
      response = Net::HTTP.get_response(uri)
      return true if response.respond_to?(:code) and response.code != nil
    rescue Errno::ECONNREFUSED
      return false
    end
    false
  end

end

