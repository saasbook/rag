require 'open3'
require 'yaml'
require 'term/ansicolor'
require 'thread'
require 'fileutils'
require 'tempfile'
require './lib/cov_helper.rb'
require './lib/util.rb'

$m_stdout = Mutex.new
$m_db = Mutex.new
$i_db = 0

Dir["./lib/graders/feature_grader/lib/*.rb"].each { |file| require file }
$CUKE_RUNNER = File.join(File.expand_path('lib/graders/feature_grader'), 'cuke_runner')
module Graders
  # +AutoGrader+ that scores using weird stuff
  class HW4Grader < AutoGrader

    attr_accessor :comments, :description
    attr_reader   :logpath
    attr_reader   :cov_opts

    ERROR_HASH = {raw_score: 0, raw_max: 100, comments: 'There was a fatal error with your submission. It either timed out or caused an exception.'}
    

    # Grade the features contained in the +.tar.gz+ archive _submission_archive_,
    # using the reference solution _app_.
    #
    # +grading_rules+ is a +Hash+ of
    # [+:description+] +String+ location of grading description [TODO document format]
    #
    # :call-seq:
    #   new(submission_archive, grading_rules, app) -> FeatureGrader

    def initialize(submission_path, assignment)
      @output = []
      @description = assignment.assignment_spec_file
      @temp = submission_path
      @submissiondir = Dir[File.join(@temp, '*')][-1]
    end

    def log(*args)

      @output += [*args]

    end

    def dump_output
      @comments = @output.join("\n")
    end
    
    def grade
      response = run_in_subprocess(method(:runner_block))
      if response
        response
      else
        ERROR_HASH
      end
    end

    private

    def runner_block
      load_description

      @raw_score = 0
      @raw_max = 0
      start_time = Time.now

      FileUtils.cp_r Dir.glob(File.join(@base_app_path, "*")), @temp
      FileUtils.cp_r Dir.glob(File.join(@submissiondir, ".")), @temp
      FileUtils.rm_r Dir.glob(@submissiondir)
      tmpdir = @temp
      Dir.chdir(tmpdir) do 
        env = {
          'RAILS_ROOT' => Dir.pwd,
          'RAILS_ENV' => 'test'
        }
        time_operation 'setup' do
          setup_rails_app(env)
        end
        separator = '-'*40  # TODO move this


        time_operation 'student tests' do
          log separator
          log "Running student tests found in features/ spec/:"
          check_student_tests(env)
          log separator
        end

        log ''
        time_operation 'coverage' do
          log separator
          log "Checking coverage for:"
          check_code_coverage
          log separator
        end

        log ''

        # Check reference cucumber
        time_operation 'reference cucumber' do
          log separator
          log 'Running reference Cucumber scenarios:'
          test_prepare(env)
          check_ref_cucumber
          log separator
        end
      end
      log "Total score: #{@raw_score} / #{@raw_max}"
      log "Completed in #{Time.now-start_time} seconds."
      dump_output
      {raw_score: @raw_score, raw_max: @raw_max, comments: @comments}
    end


    def load_description
      if File.directory? @description
        # gets the first yaml file
        dir = Dir[File.join(@description, '*.yml')]
        @description = dir[0]
      end
      y = YAML::load_file(@description)

      # Load stuff we would need
      # Directory of base app to copy over
      @base_app_path = y['base_app_path']

      # Coverage
      @cov_opts = y['coverage']
        raise ArgumentError, "No 'coverage' configuration found" unless @cov_opts
        @cov_pts = @cov_opts.delete('points').to_f
      @cov_opts = @cov_opts.convert_keys

      # Ref cucumber
      @cucumber_config = {
        :ref => y['ref_cucumber'],
        :student => y['student_cucumber']
      }.convert_keys

    end

    def setup_rails_app(env)
      setup_cmds = [
        "bundle install --without production",
        "bundle exec rake db:migrate",# db:test:prepare",
      ]
      setup_cmds.each do |cmd|
        Open3.popen3(env, cmd) do |stdin, stdout, stderr, wait_thr|
          exitstatus = wait_thr.value.exitstatus
          out = stdout.read
          err = stderr.read
          if exitstatus != 0
            raise out + err
          end
        end
      end
    end

    def test_prepare(env)
      setup_cmds = [
        "bundle exec rake db:test:prepare"
      ]
      setup_cmds.each do |cmd|
        Open3.popen3(env, cmd) do |stdin, stdout, stderr, wait_thr|
          exitstatus = wait_thr.value.exitstatus
          out = stdout.read
          err = stderr.read
          if exitstatus != 0
            raise out + err
          end
        end
      end
    end

    def check_student_tests(env)
      max_score = @cucumber_config[:student].delete :points
      cuke = rspec = ''
      @raw_max += max_score
      Open3.popen3(env, "bundle exec rake saas:run_student_tests") do |stdin, stdout, stderr, wait_thr|
        exitstatus = wait_thr.value.exitstatus
        out = stdout.read
        err = stderr.read
        if exitstatus != 0
          log err
          return
        end
        cuke, rspec = parse_student_test_output(out)
      end
      cuke_passed, cuke_max = score_cuke_output(cuke)
      rspec_passed, rspec_max = score_rspec_output(rspec)
      cuke_score = cuke_max > 0 ? Rational(cuke_passed, cuke_max) : 0
      rspec_score = rspec_max > 0 ? Rational(rspec_passed, rspec_max) : 1
      section_score = (cuke_score * max_score/2.0).to_i + (rspec_score * max_score/2.0).to_i

      log cuke if cuke_score != 1
      log rspec if rspec_score != 1
      log "  Cucumber: #{cuke_passed} out of #{cuke_max} scenarios passed"
      log "  RSpec: #{rspec_passed} out of #{rspec_max} tests passed"
      log "  Score: #{section_score}/#{max_score}"
      @raw_score += section_score
    end

    def check_code_coverage
      @raw_max += @cov_pts

      log @cov_opts[:pass_threshold].collect {|g,t| "  #{g} >= #{format '%.2f%%', t*100}"}.join("\n")
      c = CovHelper.new(File.join(Dir::getwd, 'coverage', 'index.html'), @cov_opts)
      c.parse!

      separator = '-'*40  # TODO move this
      log separator
      log c.details.collect {|line| "  #{line}"}
      log ''

      if c.correct?
        log "Passed coverage test."
        log "  Score: #{@cov_pts}/#{@cov_pts}"
        @raw_score += @cov_pts
      else
        log "Failed coverage test (#{c.failures.join(', ')} coverage too low)."
        log "  Score: 0/#{@cov_pts}"
        @raw_score += @cov_pts * (c.passes.count / (c.passes.count + c.failures.count))
      end
    rescue StandardError => e
      log "Failed coverage test (#{e.message.inspect})."
      log "  Score: 0/#{@cov_pts}"
    end

    def check_ref_cucumber
      process_ref_cucumber_config
      ENV['DRB'] = '0'  # disable drb
      ENV['FEATURE_PATH'] = File.join( Dir::getwd, 'features' )
      max_score = @cucumber_config[:ref].delete :points

      # I don't know why we only care about the first one, but the FastReturn
      # mess was only grading 1 feature anyways. Ask Richard Xia.
      feature = @cucumber_config[:ref][:features][0]
      score = HW4Grader::Feature.total([feature])
      # score = HW4Grader::Feature.total(@cucumber_config[:ref][:features])
      steps = feature.scenarios[:steps]
      if steps[:passed] != steps[:total]
        separator = '-'*40  # TODO move this
        log feature.output
        log separator
      end
      log "  #{steps[:passed]} out of #{steps[:total]} scenarios passed"
      log "  Score: #{max_score * steps[:passed]/steps[:total]}/#{max_score}"
      @raw_score += max_score * steps[:passed]/steps[:total]
      @raw_max += max_score
      #score = score.normalize(max_score)
      #log "  Score: #{score.points}/#{score.max}"
      #@raw_score += score.points
      #@raw_max   += score.max
    end

    def process_ref_cucumber_config
      y = @cucumber_config[:ref]

      # This does some hacky stuff to get references to work properly
      feature_config = {
        :base_path => Dir::getwd    # Feature base path
      }

      { :scenarios => FeatureGrader::ScenarioMatcher,
        :features  => HW4Grader::Feature
      }.each_pair do |label,klass|
        raise(ArgumentError, "Unable to find required key '#{label}' in #{@description}") unless y[label]
        y[label].each {|h| h[:object] = klass.new(self, h, feature_config)}
      end

      y[:features].each {|h| featurize(h)}

      y[:features] = y[:features].collect {|h| h[:object]}
    end

    def featurize(f)
      %w( failures ).each do |attr|
        f[attr].collect! {|h| h.is_a?(Hash) ? h[:object] : h} if f.has_key?(attr)
      end
      f[:if_pass].collect! {|h| featurize(h); HW4Grader::Feature.new(self, h, @config)} if f.has_key?(:if_pass)
    end


    def parse_student_test_output(text)
      cuke = text.match(/^----BEGIN CUCUMBER----\n#{'-'*80}\n(.*)#{'-'*80}\n----END CUCUMBER----$/m)[1]
      rspec = text.match(/^----BEGIN RSPEC----\n#{'-'*80}\n(.*)#{'-'*80}\n----END RSPEC----$/m)[1]
      [cuke, rspec]
    end

    def score_cuke_output(text)
      matches = text.match(/(\d+) scenarios \((.*)\)/)
      total, details = matches[1..2]
      total = total.to_i
      if details.match(/(\d+) passed/)
        passed = $1.to_i
      else
        passed = 0
      end
      [passed, total]
    rescue StandardError => e
      logger.debug e.to_s
      [0,0]
    end

    def score_rspec_output(text)
      matches = text.match(/(\d+) examples?, (.*)$/)
      total, details = matches[1..2]
      total = total.to_i
      if details.match(/(\d+) failures?/)
        failed = $1.to_i
      else
        failed = 0
      end
      if details.match(/(\d+) pending/)
        pending = $1.to_i
      else
        pending = 0
      end
      passed = total - failed - pending
      [passed, (total - pending)]
    rescue StandardError => e
      logger.debug e.to_s
      [0,0]
    end

    def time_operation(name=nil)
      start_time = Time.now.to_f
      yield
      end_time = Time.now.to_f
      # TODO: Make this a debug mode setting
      logger.debug "#{name}: #{end_time - start_time}s"
    end
  end
end
