# Runs some code wrapped in a given environment.
# Sets environment variables, then restores them after +yield+ing.

def with_env(env={})
  raise ArgumentError, "Block required" unless block_given?
  prev_env = {}

  # Save old ENV
  env.each_pair do |k,v|
    k = k.to_s
    prev_env[k] = ENV[k]
    ENV[k] = v.to_s
  end

  yield

  # Restore original ENV
  env.each_key do |k|
    k = k.to_s
    ENV[k] = prev_env[k]
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
      @env[:FEATURE] = @env.delete(:feature)
      with_env(@env) do
        h = @env.dup
        target_status = h.has_key?(:pass) ? h.delete(:pass) : true
        puts "Cuking with #{h.inspect}"

         passed = true
         begin
           #Cucumber::Rake::Task.new({:ok => 'db:test:prepare'}, 'derp').runner.run
           c = Cucumber::Runtime.new(Cucumber::Cli::Configuration.new)
           c.run!
           passed = !c.results.failure?
         rescue => e
           raise TestFailedError, "test failed to run b/c #{e.inspect}"
         end

#        status = !! system("rake cucumber #{h.collect{|k,v| [k,v].join("=")}.join(' ')}", :chdir => Dir::getwd)
#        puts "cuke returned #{status} (#{$?.inspect})"
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

    puts "Booting #{app}..."
    # requires have to be in this exact order
    require 'cucumber/rake/task'
    require File.join(app, 'config', 'environment.rb')
    require 'rake'
    #load File.join(app, 'lib', 'tasks', 'cucumber.rake')
  end

  def grade!
    load_description
    d = Dir::getwd
    Dir::chdir @app

    @raw_score = 0
    @raw_max = @features.count

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
