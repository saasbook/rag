require 'simplecov'
SimpleCov.start

require 'grader'
require 'auto_grader'
require 'graders/rspec_grader/rspec_grader'
require 'graders/rspec_grader/weighted_rspec_grader'
require 'graders/rspec_grader/rspec_runner'
require "graders/rspec_grader/github_rspec_grader"

require 'coursera_submission'
require 'base64'
require 'json'

require 'coursera_controller'
require 'coursera_client'
