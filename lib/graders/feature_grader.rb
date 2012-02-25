# Runs some code wrapped in a given environment.
# Sets environment variables, then restores them after +yield+ing.

def with_env(env={})
  raise ArgumentError, "Block required" unless block_given?
  prev_env = {}

  env[:RAILS_ENV] ||= 'test'

  # Save old ENV
  env.each_pair do |k,v|
    k = k.to_s
    prev_env[k] = ENV[k]
    ENV[k] = v.to_s
  end

  begin
    yield
  rescue => e
    raise
  ensure
    # Restore original ENV
    env.each_key do |k|
      k = k.to_s
      ENV[k] = prev_env[k]
    end
  end
end

class Hash
  def symbolize_keys
    h = {}
    self.each_pair { |k,v| h[k.to_sym] = v }
    return h
  end
end

require 'term/ansicolor'
class String
  include Term::ANSIColor
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

    attr_reader :env

    # +env+ is a +Hash+ containing
    # [+:feature+] path to feature file
    # [+:pass+]    +boolean+ specifying whether the spec should pass or not
    # [...]        and any other environment variables

    def initialize(env={})
      raise ArgumentError, "No :feature specified" unless env[:feature]
      @env = env
    end

    def run!
      h = @env.dup

      # Extract params
      feature = h.delete(:feature)
      target_status = h.has_key?(:pass) ? h.delete(:pass) : true

      # Leftover h is env vars
      with_env(h) do
        puts "Cuking with #{h.inspect}"

        passed = true
        begin
          config = Cucumber::Cli::Configuration.new
          config.parse! [feature]

          c = Cucumber::Runtime.new(config)
          c.run!

          puts "out of #{c.results.scenarios.count} #{c.results.steps.count}:".yellow.bold
          puts "  failed #{c.results.scenarios(:failed).count} #{c.results.steps(:failed).count}".yellow.bold
          puts "  passed #{c.results.scenarios(:passed).count} #{c.results.steps(:passed).count}".yellow.bold

          passed = !c.results.failure?
        rescue => e
          raise TestFailedError, "test failed to run b/c #{e.inspect}"
        end

        if target_status == passed
          puts "Test #{h.inspect} was correct (#{target_status})".green
        else
          puts "Test #{h.inspect} failed (#{passed} instead of #{target_status})".red
          raise TestFailedError, "Result should have been #{target_status}"
        end
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
        f = f.symbolize_keys
        @features << Feature.new(f)
      end
    rescue => e
      raise
    end
  end

end

class HW3Grader < FeatureGrader
end
