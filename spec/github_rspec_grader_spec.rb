require 'spec_helper'

describe "GithubRspecGrader" do

  before do
    File.should_receive(:readable?).with('github_spec.rb') .and_return true
    ENV.should_receive(:[]=).with('GITHUB_USERNAME','username')
  end

  it 'should set environmental variable correctly' do
    GithubRspecGrader.new('username',{:spec => 'github_spec.rb'})
  end

  it 'should handle trailing spaces' do
    GithubRspecGrader.new(' username ',{:spec => 'github_spec.rb'})
  end

  it 'should handle trailing line endings' do
    GithubRspecGrader.new("username\n",{:spec => 'github_spec.rb'})
  end

  it 'should handle trailing line endings from windows' do
    GithubRspecGrader.new("username\n\r",{:spec => 'github_spec.rb'})
  end
end