require 'open3'
require 'yaml'
require 'term/ansicolor'
require 'thread'
require 'fileutils'
require 'tempfile'

Dir["./lib/graders/feature_grader/lib/*.rb"].each { |file| require file }
$CUKE_RUNNER = File.join(File.expand_path('lib/graders/feature_grader'), 'cuke_runner')

module Graders
  class FeatureGrader < AutoGrader
    attr_reader   :features
    attr_accessor :comments

  	ERROR_HASH = {raw_score: 0, raw_max: 100, comments: 'There was a fatal error with your submission. It either timed out or caused an exception.'}
  	# +.tar.gz+ archive should have been already unarchived and submission_path
  	# directs to the unarchived folder

  	def initialize (submission_path, assignment)
  		@output = []
  		@features = []
      @submission_path = submission_path
  		@spec_file_path = assignment.assignment_spec_file
  		raise NoSuchSpecError, 'Specs could not be found' unless File.readable? @spec_file_path
  	end

  	def log(*args)
      @output += [*args]
  	end

  	def ref_app
  		ENV['RAILS_ROOT'] = @base_app_path
  	end

  	def grade
  		ENV['RAILS_ENV'] = 'test'
  		ref_app
  		response = run_in_subprocess(method(:runner_block))
  		if response
  			response
  		else
  			ERROR_HASH
  		end
  	end

  	def compute_points (file_path)
  		load_description
  		score = Feature.total(@features)   # TODO: integrate Score
  		@raw_score, @raw_max = score.points, score.max

  		log "Total score: #{@raw_score} / #{@raw_max}"
  		log "Completed in #{Time.now - start_time} seconds."
  	end

  	def runner_block
  	  compute_points(@spec_file_path)
  	  @comments = @outputs.join("\n")
  	  {raw_score: @raw_score, raw_max: @raw_max, comments: @comments}
  	end

  	private

  	def load_description
  	  y = YAML::load_file(@spec_file_path)
  	  @base_app_path = y['base_app_path']
  	  # This does some hacky stuff to get references to work properly
  	  @config = {
  	    :path => @submission_path
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