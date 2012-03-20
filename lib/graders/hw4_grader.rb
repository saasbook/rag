require 'open3'
require 'yaml'
require 'term/ansicolor'
require 'thread'
require 'fileutils'
require 'tempfile'
require 'tmpdir'
require './lib/cov_helper.rb'
require './lib/util.rb'

$m_stdout = Mutex.new
$m_db = Mutex.new
$i_db = 0

Dir["lib/graders/feature_grader/*.rb"].each { |file| load file }
$CUKE_RUNNER = File.join(File.expand_path('lib/graders/feature_grader'), 'cuke_runner')

# +AutoGrader+ that scores using weird stuff
class HW4Grader < AutoGrader

  class ScenarioMatcher
    attr_reader :regex, :desc

    # [+"match"+] +String+ regular expression for matching +cucumber+ output
    def initialize(grader, h, config={})
      raise(ArgumentError, "no regex") unless @regex = h["match"]

      @config = config
      @desc = h["desc"] || h["match"]
      @regex = /#{@regex}/
    end

    # [+str+] _String_ to match against
    def match?(str)
      !!(str =~ @regex)
    end

    def to_s
      @desc
    end
  end

  attr_accessor :submission_archive, :description
  attr_reader   :logpath
  attr_reader   :cov_opts

  # Grade the features contained in the +.tar.gz+ archive _submission_archive_,
  # using the reference solution _app_.
  #
  # +grading_rules+ is a +Hash+ of
  # [+:description+] +String+ location of grading description [TODO document format]
  #
  # :call-seq:
  #   new(submission_archive, grading_rules, app) -> FeatureGrader

  def initialize(submission_archive, grading_rules={})
    @output = []
    @m_output = Mutex.new

    unless @submission_archive = submission_archive and File.file? @submission_archive and File.readable? @submission_archive
      raise ArgumentError, "Unable to find submission archive #{@submission_archive.inspect}"
    end

    unless @description = (grading_rules[:spec] || grading_rules[:description]) and File.file? @description and File.readable? @description
      raise ArgumentError, "Unable to find description file #{@description.inspect}"
    end

    $config = {:mt => grading_rules.has_key?(:mt) ? grading_rules[:mt] : true} # TODO merge all the configs
    $config[:mt] = (ENV["AG_MT"] =~ /1|true/i) if ENV.has_key?("AG_MT")
    $config[:mt] = false

    @temp = TempArchiveFile.new(@submission_archive)
    @logpath = File.expand_path(File.join('.', 'log', "hw4_#{File.basename @temp.path}.log"))
  end

  def log(*args)
    @m_output.synchronize do
      @output += [*args]
    end
  end

  def dump_output
    self.comments = @output.join("\n")
    @m_output.synchronize do
      STDOUT.puts *@output
      File.open(@logpath, 'a') {|f| f.puts *@output}
    end
  end

  def grade!
    begin
      load_description

      @raw_score = 0
      @raw_max = 0
      start_time = Time.now

      Dir.mktmpdir('hw4_grader', '/tmp') do |tmpdir|
        # Copy base app
        FileUtils.cp_r Dir.glob(File.join(@base_app_path,"*")), tmpdir

        # Copy submission files over base app
        ## TODO: Double check that file structure is correct
        FileUtils.cp_r Dir.glob(File.join(@temp.path,"/*")), tmpdir

        # Cleanup things
        FileUtils.rm_rf File.join(tmpdir, "coverage")

        setup_cmds = [
          "bundle install --without production",
          "rake db:migrate db:test:prepare",
        ]
        Dir.chdir(tmpdir) do 
          env = {
            'RAILS_ROOT' => tmpdir
          }
          setup_cmds.each do |cmd|
            Open3.popen3(env, cmd) do |stdin, stdout, stderr, wait_thr|
              exitstatus = wait_thr.value.exitstatus
              out = stdout.read
              err = stderr.read
              if exitstatus != 0
                raise err
              end
            end
          end
          Open3.popen3(env, "rake saas:run_student_tests") do |stdin, stdout, stderr, wait_thr|
            exitstatus = wait_thr.value.exitstatus
            out = stdout.read
            err = stderr.read
            puts out
            puts err
            if exitstatus != 0
              raise err
            end
            cuke, rspec = parse_student_test_output(out)
            cuke_score = score_cuke_output(cuke)
            rspec_score = score_rspec_output(rspec)
            @raw_score += (cuke_score * 100).to_i
            @raw_score += (rspec_score * 100).to_i
          end

          # Check coverage
          check_code_coverage

          # Check reference cucumber
          check_ref_cucumber
        end
      end

      log "Total score: #{@raw_score} / #{@raw_max}"
      log "Completed in #{Time.now-start_time} seconds."
      dump_output
    ensure
      @temp.destroy if @temp
    end
  end

  private

  def load_description
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

  def check_code_coverage
    @raw_max += @cov_pts
    separator = '-'*40  # TODO move this

    log ''
    log separator
    log "Checking coverage for:"
    log @cov_opts[:pass_threshold].collect {|g,t| "  #{g} >= #{format '%.2f%%', t*100}"}.join("\n")
    log separator

    c = CovHelper.new(File.join(Dir::getwd, 'coverage', 'index.html'), @cov_opts)
    c.parse!

    log c.details.collect {|line| "  #{line}"}
    log ''

    if c.correct?
      log "Passed coverage test."
      @raw_score += @cov_pts
    else
      log "Failed coverage test (#{c.failures.join(', ')} coverage too low)."
      @raw_score += @cov_pts * (c.passes.count / (c.passes.count + c.failures.count))
    end

    log separator
    log ''
  end

  def check_ref_cucumber
    process_ref_cucumber_config
    ENV['DRB'] = '0'  # disable drb
    ENV['FEATURE_PATH'] = File.join( Dir::getwd, 'features' )
    max_score = @cucumber_config[:ref].delete :points
    score = FeatureGrader::Feature.total(@cucumber_config[:ref][:features])
    score = score.normalize(max_score)
    @raw_score += score.points
    @raw_max   += score.max
  end

  def process_ref_cucumber_config
    y = @cucumber_config[:ref]

    # This does some hacky stuff to get references to work properly
    feature_config = {
      :base_path => Dir::getwd    # Feature base path
    }

    { :scenarios => FeatureGrader::ScenarioMatcher,
      :features  => FeatureGrader::Feature
    }.each_pair do |label,klass|
      raise(ArgumentError, "Unable to find required key '#{label}' in #{@description}") unless y[label]
      y[label].each {|h| h[:object] = klass.new(self, h, feature_config)}
    end

    objectify = lambda {|arr| arr.collect! {|h| h[:object]}}
    featurize = lambda do |f|
      %w( failures ).each do |attr|
        f[attr].collect! {|h| h.is_a?(Hash) ? h[:object] : h} if f.has_key?(attr)
      end

      f[:if_pass].collect! {|h| featurize.call(h); FeatureGrader::Feature.new(self, h, feature_config)} if f.has_key?(:if_pass)
    end

    y[:features].each {|h| featurize.call(h)}

    y[:features] = y[:features].collect {|h| h[:object]}
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
    Rational(passed, total)
  rescue Error => e
    puts e.to_s
    0
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
    Rational(passed, total - pending)
  rescue Error => e
    puts e.to_s
    0
  end

end
