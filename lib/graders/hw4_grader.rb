require 'open3'
require 'yaml'
require 'term/ansicolor'
require 'thread'
require 'fileutils'
require 'tempfile'
require 'tmpdir'

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

      #ENV['RAILS_ENV'] = 'test'

      start_time = Time.now

      @raw_score = 0
      @raw_max = 500

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
            if exitstatus != 0
              raise err
            end
            #"rake cucumber",
            #"rake spec",
          end
        end

        # Check coverage
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
  end

end
