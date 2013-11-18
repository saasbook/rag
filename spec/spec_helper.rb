require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

RSpec.configure do |c|
  c.filter_run_excluding :sandbox => true
end

require 'grader'
require 'auto_grader'
require 'auto_grader_subprocess'
require 'graders/rspec_grader/rspec_grader'
require 'graders/rspec_grader/weighted_rspec_grader'
require 'graders/rspec_grader/rspec_runner'
require "graders/rspec_grader/github_rspec_grader"

require 'coursera_submission'
require 'base64'
require 'json'

require 'coursera_controller'
require 'coursera_client'

require 'edx_client'
require 'edx_controller'
require 'edx_submission'

require 'run_with_timeout'
