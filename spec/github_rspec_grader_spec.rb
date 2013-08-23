require 'spec_helper'

describe "GithubRspecGrader" do
  let(:grader) do
    grader.should_receive(:super).with('',{:spec => 'github_spec.rb'}).and_return nil
    ENV.should_receive(:[]=).with('GITHUB_USERNAME','username')
    GithubRspecGrader.new('username',{:spec => 'github_spec.rb'})
  end
  xit 'should show up in the test coverage' do

  end
end