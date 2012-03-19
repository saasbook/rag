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

      Dir.mktmpdir('hw4_grader') do |tmpdir|
        # Copy base app
        FileUtils.cp_r Dir.glob(File.join(@base_app_path,"*")), tmpdir

        # Copy submission files over base app
        ## TODO: Double check that file structure is correct
        FileUtils.cp_r Dir.glob(File.join(@temp.path,"/*")), tmpdir

        # Cleanup things
        FileUtils.rm_rf File.join(tmpdir, "coverage")

#        puts "Go #{tmpdir}"
#        STDIN.gets

        setup_cmds = [
          "bundle install --without production",
          "rake db:migrate db:test:prepare",
          "rake cucumber spec",
#          "rake spec",
        ]
        Dir.chdir(tmpdir) do 
          puts `pwd`
          # Run raketask?
          setup_cmds.each do |cmd|
#            puts "go #{cmd}"
#            STDIN.gets
            env = {
              'RAILS_ROOT' => tmpdir
            }
            Open3.popen3(env, cmd) do |stdin, stdout, stderr, wait_thr|
              exitstatus = wait_thr.value.exitstatus
              puts stdout.read
              puts stderr.read
              if exitstatus != 0
                #raise stderr.read
              end
            end
          end
        end

        # Check coverage
        check_code_coverage(tmpdir)
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
    @cov_opts = y['coverage']
      raise ArgumentError, "No 'coverage' configuration found" unless @cov_opts
      @cov_pts = @cov_opts.delete('points').to_f
    @cov_opts = @cov_opts.convert_keys
  end

  def check_code_coverage(tmpdir)
    @raw_max += @cov_pts
    separator = '-'*40  # TODO move this

    log ''
    log separator
    log "Checking coverage for:"
    log @cov_opts[:pass_threshold].collect {|g,t| "  #{g} >= #{format '%.2f%%', t*100}"}.join("\n")
    log separator

    c = CovHelper.new(File.join(tmpdir, 'coverage', 'index.html'), @cov_opts)
    c.parse!

    log c.details.collect {|line| "  #{line}"}
    log ''

    if c.correct?
      log "Passed coverage test."
      @raw_score += @cov_pts
    else
      log "Failed coverage test (#{c.failures.join(', ')} coverage too low)."
    end

    log separator
    log ''
  end

end
