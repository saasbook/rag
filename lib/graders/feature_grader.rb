require 'open3'
require 'yaml'
require 'term/ansicolor'
require 'thread'
require 'fileutils'

$m_stdout = Mutex.new
$m_db = Mutex.new
$i_db = 0

class String
  include Term::ANSIColor
end

class Hash
  # Returns a new +Hash+ containing +to_s+ed keys and values from this +Hash+.

  def envify
    h = {}
    self.each_pair { |k,v| h[k.to_s] = v.to_s }
    return h
  end
end

class Score
  attr_accessor :points, :max

  def initialize(points=0, max_points=0)
    @points = points
    @max    = max_points
  end

  def +(other)
    case other
    when Score
      Score.new(@points+other.points, @max+other.max)
    when Integer
      Score.new(@points+other, @max+other)
    else
      raise ArgumentError
    end
  end

  def pass()
    @points += 1
    @max += 1
  end

  def fail()
    @max += 1
  end

  def to_s
    "#{@points} / #{@max}"
  end
end

def log(*args)
  $m_stdout.synchronize { puts *args }
end

# +AutoGrader+ that scores using cucumber features
class FeatureGrader < AutoGrader

  class ScenarioMatcher
    attr_reader :regex

    # [+"match"+] +String+ regular expression for matching +cucumber+ output
    def initialize(h)
      raise(ArgumentError, "no regex") unless @regex = h["match"]

      @regex = /#{@regex}/
    end

    # [+str+] _String_ to match against
    def match?(str)
      !!(str =~ @regex)
    end
  end

  class Feature
    class TestFailedError < StandardError; end

    module Regex
      BlankLine = /^$/
      FailingScenarios = /^Failing Scenarios:$/
      StepResult = /^(\d+) steps \(.*?(\d+) passed.*\)/
    end

    attr_reader :if_pass, :target_pass, :feature, :score

    # +Array+ of +ScenarioMatcher+s that should fail for this step,
    # or empty if it should pass in +cucumber+.
    attr_reader :failures

    # +Hash+ with
    # [+:failed+] [_String_] +cucumber+ scenarios that failed
    attr_reader :scenarios

    class << self
      def total(features=[])
        s = Score.new
        m = Mutex.new
        threads = []
        features.each do |f|
          t = Thread.new do
            begin
              result = f.run!
              m.synchronize { s += result }
            rescue TestFailedError
              m.synchronize { s.fail }
            end
          end
          threads << t
        end
        threads.each(&:join)
        return s
      end
    end

    # +feature+ is a +Hash+ containing
    # [+:FEATURE+] path to feature file
    # [+:pass+]    +boolean+ specifying whether the feature should pass or not
    # [+:if_pass+] additonal +Feature+s to run iff this one passes (recursive +Hash+ structure)
    # [+:failures+] +ScenarioMatcher+s that indicate which scenarios should fail
    #               for this step
    # [...]        and any other environment variables

    def initialize(feature_={})
      feature = feature_.dup
      raise ArgumentError, "No 'FEATURE' specified in #{feature.inspect}" unless feature['FEATURE']

      @score = Score.new

      @if_pass = []
      if feature["if_pass"] and feature["if_pass"].is_a? Array
        @if_pass += feature.delete("if_pass").collect {|f| Feature.new(f)}
      end

      @target_pass = feature.has_key?("pass") ? feature.delete("pass") : true

      @failures = feature.delete("failures") || []
      @scenarios = {:failed => []}

      @env = feature.envify  # whatever's left over
    end

    def run!
      log '-'*80

      h = @env.dup

      score = Score.new
      num_failed = 0
      passed = false
      lines = []

      $m_db.synchronize do
        h["TEST_DB"] = "db/test_#{$i_db}.sqlite3"
        $i_db += 1
      end
      popen_opts = {
        #:unsetenv_others => true     # TODO why does this make cucumber not work?
      }

      log "Cuking with #{h.inspect}"

      begin
        raise TestFailedError, "Nonexistent feature file #{h["FEATURE"]}" unless File.readable? h["FEATURE"]

        FileUtils.cp "db/test.sqlite3", h["TEST_DB"]
        Open3.popen3(h, "bundle exec rake cucumber", popen_opts) do |stdin, stdout, stderr, wait_thr|
          exit_status = wait_thr.value

          lines = stdout.readlines
          lines.each(&:chomp!)
          self.send :process_output, lines
        end

      rescue => e
        log "test failed: #{e.inspect}".red.bold
        log e.backtrace
        raise TestFailedError, "test failed to run b/c #{e.inspect}"

      ensure
        FileUtils.rm h["TEST_DB"]

      end

      if self.correct?
        log "Test #{h.inspect} passed.".green
        score.pass
        score += Feature.total(@if_pass)
      else
        log "Test #{h.inspect} failed".red
        begin
          self.correct!
        rescue TestFailedError => e
          log e.message
        end
        log lines.collect {|l| "| #{l}"}
        score.fail
      end

      return score
    end

    def correct?
      begin
        correct!
        return true
      rescue
        return false
      end
    end

    # This step is correct if:
    #   any +failures+ +?+ all +failures+ have failed +:+ it passed in cucumber
    def correct!
      if @failures.any?
        unless @failures.all? {|matcher| @scenarios[:failed].any? {|s| matcher.match? s}}
          raise TestFailedError, "Not all required failures were detected"
        end
      else
        unless @scenarios[:failed].empty?
          raise TestFailedError, "Feature should have passed, but had the following failures:\n#{@scenarios[:failed].collect {|f| "  #{f}"}}"
        end
      end
      true
    end

  private
    # Parses and remembers relevant output from +cucumber+.
    # [+output+] +Array+ of stdout lines from +rake cucumber+, e.g. from +readlines+
    def process_output(output)
      raise ArgumentError unless output and output.is_a? Array

      begin # parse failing scenarios (between FailingScenarios and BlankLine)
        if i = output.find_index {|line| line =~ Regex::FailingScenarios}
          temp = output[i+1..-1]
          i = temp.find_index {|line| line =~ Regex::BlankLine}
          @scenarios[:failed] = temp.first(i)
        end
      rescue => e
        raise
      end

#      result_lines = lines.grep Regex::StepResult
#
#      raise TestFailedError unless result_lines.count == 1
#
#      num_steps, num_passed = result_lines.first.scan(Regex::StepResult).first
#      passed = (num_steps == num_passed)
    end

  end

  attr_accessor :features_archive, :description
  attr_reader   :features

  # Grade the features contained in the +.tar.gz+ archive _features_archive_,
  # using the reference solution _app_.
  #
  # +grading_rules+ is a +Hash+ of
  # [+:description+] +String+ location of grading description [TODO document format]
  #
  # :call-seq:
  #   new(features_archive, grading_rules, app) -> FeatureGrader

  def initialize(features_archive, grading_rules={}, app)
    @features = []
    @app = app

    unless @features_archive = features_archive and File.file? @features_archive and File.readable? @features_archive
      raise ArgumentError, "Unable to find features archive #{@features_archive.inspect}"
    end

    unless @description = grading_rules[:description] and File.file? @description and File.readable? @description
      raise ArgumentError, "Unable to find description file #{@description.inspect}"
    end

  end

  def grade!
    load_description

    d = Dir::getwd
    Dir::chdir @app
    ENV['RAILS_ENV'] = 'test'

    start_time = Time.now

    score = Feature.total(@features)   # TODO integrate Score
    @raw_score, @raw_max = score.points, score.max

    log "Completed in #{Time.now-start_time} seconds.".yellow  # TODO remove this
    Dir::chdir d
  end

  private

  def load_description
    puts "Loading #{@description}..."
    y = YAML::load_file(@description)

    # This does some hacky stuff to get references to work properly

    { "scenarios" => ScenarioMatcher,
      "features"  => Feature
    }.each_pair do |label,klass|
      y[label].each {|h| h[:object] = klass.new(h)}
    end

    objectify = lambda {|arr| arr.collect! {|h| h[:object]}}
    featurize = lambda do |f|
      %w( failures ).each do |attr|
        f[attr].collect! {|h| h.is_a?(Hash) ? h[:object] : h} if f.has_key?(attr)
      end

      f["if_pass"].collect! {|h| featurize.call(h); Feature.new(h)} if f.has_key?("if_pass")
    end

    y["features"].each {|h| featurize.call(h)}

    @features = y["features"].collect {|h| h[:object]}
  end

end

class HW3Grader < FeatureGrader
end
