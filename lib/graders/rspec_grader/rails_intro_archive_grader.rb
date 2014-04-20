require_relative 'heroku_rspec_grader'

class RailsIntroArchiveGrader < HerokuRspecGrader
  def initialize(archive, grading_rules)
    super('', grading_rules)
    #TODO make it other than port 3000
    @heroku_uri = 'http://localhost:3000'
    @archive = archive
  end

  def grade!
    ENV['HEROKU_URI'] = @heroku_uri
    Dir.mktmpdir('rails_intro_archive', '/tmp') do |tmpdir|
      @temp = tmpdir
      untar_cmd = "tar -xvf #{@archive} -C /#{@temp}"
      `#{untar_cmd}`
      pid = Process.fork do
        run_process('rails s', @temp)
      end
      rails_up_timeout(30)
      super
      pid = `pgrep -f "ruby script/rails s"`
      Process.kill('INT', pid.to_i)
      Process.kill('KILL', pid.to_i)
    end
  end

  def run_process(cmd, dir)
      @output, @errors, @status = Open3.capture3(
          cmd, :chdir => dir
      )
      puts (cmd +
          @output +
          @errors +
          @status.to_s) unless @status.success? and @errors == ''
  end

  def rails_up_timeout(sec, polling=1)
    to_status = timeout(sec) {
      sleep(polling) until app_loaded?
    }
  end

  def app_loaded?
    begin
      require 'net/http'
      uri = URI.parse("http://127.0.0.1:3000/movies/")
      response = Net::HTTP.get_response(uri)
      return true if response.respond_to?(:code) and response.code != nil
    rescue Errno::ECONNREFUSED
      return false
    end
    false
  end

end

