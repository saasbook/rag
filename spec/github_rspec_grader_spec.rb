require 'auto_grader'
require 'graders/rspec_grader/rspec_grader'
require 'graders/rspec_grader/weighted_rspec_grader'
require 'graders/rspec_grader/rspec_runner'
require "graders/rspec_grader/github_rspec_grader"

describe "GithubRspecGrader" do
  let(:grader) do
    grader.should_receive(:super).with('',{:spec => 'github_spec.rb'}).and_return nil
    ENV.should_receive(:[]=).with('GITHUB_USERNAME','username')
    GithubRspecGrader.new('username',{:spec => 'github_spec.rb'})
  end
end