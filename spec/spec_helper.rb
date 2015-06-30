require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

module DoubleAliases
  def mock(*args, &block)
    double(*args, &block)
  end
  alias stub mock
end

RSpec.configure do |config|
  config.include DoubleAliases
end

RSpec.configure do |c|
  c.filter_run_excluding :sandbox => true
  # c.raise_errors_for_deprecations!
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

require 'adapter'
require 'submission/xqueue.rb'

require 'fakeweb'

FakeWeb.allow_net_connect = false 