require 'open3'
require 'yaml'
require 'term/ansicolor'
require 'thread'
require 'fileutils'
require 'tempfile'

Dir["./lib/graders/feature_grader/lib/*.rb"].each { |file| require file }
$CUKE_RUNNER = File.join(File.expand_path('lib/graders/feature_grader'), 'cuke_runner')

# +AutoGrader+ that scores using cucumber features
module Graders
  class FeatureGrader < AutoGrader

    attr_accessor :comments
    attr_reader   :features

    ERROR_HASH = {raw_score: 0, raw_max: 100, comments: 'There was a fatal error with your submission. It either timed out or caused an exception.'}


    # Grade the features contained in the +.tar.gz+ archive _features_archive_,
    # using the reference solution _app_.
    #
    # +grading_rules+ is a +Hash+ of
    # [+:description+] +String+ location of grading description [TODO document format]
    #
    # :call-seq:
    #   new(features_archive, grading_rules, app) -> FeatureGrader

    # submission_path is already unarchived before it gets here
    # TODO: assignment might need to contain path to rottenpotatoes (the app) "assignment[:app]"
    def initialize(submission_path, assignment)
      @output = []
      @features = []
      @description = assignment.assignment_spec_file
      @temp = submission_path
      @timeout = 60
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

      ENV['RAILS_ENV'] = 'test'
      ENV['RAILS_ROOT'] = @base_app_path

      start_time = Time.now

      score = Feature.total(@features)   # TODO: integrate Score

      @raw_score, @raw_max = score.points, score.max

      log "Total score: #{@raw_score} / #{@raw_max}"
      log "Completed in #{Time.now - start_time} seconds."
      
      dump_output
      {raw_score: @raw_score, raw_max: @raw_max, comments: @comments}
    end

    def load_description
      if File.directory? @description
        # gets the first yaml file
        dir = Dir[File.join(@description, '*.yml')]
        @description = dir[0]
      end
      y = YAML.load_file(@description)
      @base_app_path = y['base_app_path']
      # This does some hacky stuff to get references to work properly
      @config = {
        :path => @temp
      }

      { "scenarios" => ScenarioMatcher,
        "features"  => Feature
      }.each_pair do |label,klass|
        raise(ArgumentError, "Unable to find required key '#{label}' in #{@description}") unless y[label]
        y[label].each {|h| h[:object] = klass.new(self, h, @config)}
      end

      y["features"].each {|h| featurize(h)}

      @features = y["features"].collect {|h| h[:object]}

    end
    def featurize(f)
      %w( failures ).each do |attr|
        f[attr].collect! {|h| h.is_a?(Hash) ? h[:object] : h} if f.has_key?(attr)
      end
      f["if_pass"].collect! {|h| featurize(h); Feature.new(self, h, @config)} if f.has_key?("if_pass")
    end
  end
end

