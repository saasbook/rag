# Runs some code wrapped in a given environment.
# Sets environment variables, then restores them after +yield+ing.

require 'term/ansicolor'
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

  # Merge in some critical environment variables
  def merge_ruby_env!
    %w(
      BUNDLE_BIN_PATH
      BUNDLE_GEMFILE
      PATH
    ).each { |k| self[k] = ENV[k] }
  end
end

class NilClass
  def empty?
    true
  end
end

# +AutoGrader+ that scores using cucumber features
class FeatureGrader < AutoGrader

  require 'yaml'

  class Feature
    class TestFailedError < StandardError; end

    module Regex
      StepResult = /^\d+ steps \((\d+)/
      NumFailed  = /(\d+) failed/
    end

    attr_reader :env

    # +env+ is a +Hash+ containing
    # [+:feature+] path to feature file
    # [+:fail+]    +boolean+ specifying whether the spec should pass or not,
    #              _or_ +int+ specifying exact step failure count
    # [...]        and any other environment variables

    def initialize(env={})
      raise ArgumentError, "No 'FEATURE' specified in #{env.inspect}" unless env['FEATURE']
      @env = env
    end

    def run!
      puts '-'*80

      h = @env.dup
      #h.merge_ruby_env!

      target_failed = h.has_key?("fail") ? h.delete("fail") : 0
      num_failed = 0
      passed = false
      lines = []

      popen_opts = {
        #:unsetenv_others => true     # TODO why does this make cucumber not work?
      }

      puts "Cuking with #{h.inspect}"

      begin
#          config = Cucumber::Cli::Configuration.new
#          config.parse! [feature]
#
#          c = Cucumber::Runtime.new(config)
#          c.run!

        raise TestFailedError, "Nonexistent feature file #{h["FEATURE"]}" unless File.readable? h["FEATURE"]

        Open3.popen3(h, "bundle exec rake cucumber", popen_opts) do |stdin, stdout, stderr, wait_thr|
          exit_status = wait_thr.value

          lines = stdout.readlines
          result_lines = lines.grep Regex::StepResult

          puts "result_lines failed: #{result_lines.count}".red.bold unless result_lines.count == 1
          puts lines unless result_lines.count == 1
          raise TestFailedError unless result_lines.count == 1

          num_failed = result_lines.first.scan(Regex::NumFailed).flatten.first || "0"
          puts "num_failed = #{num_failed}".yellow
        end

        passed = (target_failed == num_failed)  # these need to both be Strings

      rescue => e
        puts "test failed: #{e.inspect}".red.bold
        puts e.backtrace
        raise TestFailedError, "test failed to run b/c #{e.inspect}"

      end

      if passed
        puts "Test #{h.inspect} was correct (failed #{target_failed})".green

      else
        puts "Test #{h.inspect} failed (#{num_failed} instead of #{target_failed})".red
        puts lines.collect {|l| "| #{l}"}
        raise TestFailedError, "Failed #{num_failed} steps instead of #{target_failed}"

      end
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

    ENV['RAILS_ENV'] = 'test'

    puts "Booting #{app}..."
    # requires have to be in this exact order
    require 'cucumber'
    require 'cucumber/rake/task'

    require File.join(app, 'config', 'environment.rb')
    require 'rake'

  end

  def grade!
    load_description
    d = Dir::getwd
    Dir::chdir @app

    @raw_score = 0
    @raw_max = @features.count

    puts "Preparing database..."
    `rake db:test:prepare`

    @features.each do |f|
      begin
        f.run!
        @raw_score += 1
      rescue Feature::TestFailedError
      rescue => e
        raise
      end
    end
    Dir::chdir d
  end

  private

  def load_description
    begin
      puts "Loading #{@description}..."
      y = YAML.load_file(@description)

      unless features = y["features"] and features.is_a? Array
        raise ArgumentError, "Malformed description file"
      end

      features.each do |f|
        @features << Feature.new(f.envify)
      end
    rescue => e
      raise
    end
  end

end

class HW3Grader < FeatureGrader
end
