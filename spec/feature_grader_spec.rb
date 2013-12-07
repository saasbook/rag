require 'spec_helper'

describe FeatureGrader do
  describe '#new' do
    it "should give error if it cannot find the features archive file" do
      File.should_receive(:file?).with('foo').and_return false
      lambda { FeatureGrader.new('foo', {}) }.should raise_error ArgumentError, /features/
    end
    it "should give error if it cannot find the description file" do
      File.should_receive(:file?).with('foo').and_return true
      File.should_receive(:readable?).with('foo').and_return true
      File.should_receive(:file?).with('none.yml').and_return false
      lambda { FeatureGrader.new('foo', {:description => 'none.yml'}) }.should raise_error ArgumentError, /description/
    end
    it "sets up a log path" do
      TempArchiveFile.stub(:new).and_return(double("path", :path=>"/tmp"))
      File.should_receive(:file?).with('foo').and_return true
      File.should_receive(:readable?).with('foo').and_return true
      File.should_receive(:file?).with('hw3.yml').and_return true
      File.should_receive(:readable?).with('hw3.yml').and_return true
      expect(FeatureGrader.new('foo', {:description => 'hw3.yml'}).logpath).not_to be_nil
    end
  end
end