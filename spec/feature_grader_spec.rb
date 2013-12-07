require 'spec_helper'

describe FeatureGrader do
  it "should give error when initializing and it cannot find the features archive file" do
    lambda { FeatureGrader.new('foo', {:description => 'hw3.yml'}) }.should raise_error ArgumentError, /features/
  end
  it "should give error when initializing and it cannot find the features archive file" do
    File.should_receive(:file?).with('foo').and_return true
    File.should_receive(:readable?).with('foo').and_return true
    File.should_receive(:file?).with('none.yml').and_return false
    lambda { FeatureGrader.new('foo', {:description => 'none.yml'}) }.should raise_error ArgumentError, /description/
  end
end