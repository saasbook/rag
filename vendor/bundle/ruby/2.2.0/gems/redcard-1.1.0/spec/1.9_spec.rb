require 'spec_helper'

describe "Ruby version requirement" do
  before do
    redcard_save_state
    redcard_unload "redcard/1.9"
  end

  after do
    redcard_restore_state
  end

  it "succeeds if RUBY_VERSION is 1.9.0" do
    redcard_version "1.9.0"
    expect { require 'redcard/1.9' }.not_to raise_error
  end

  it "succeeds if RUBY_VERSION is 1.9.9" do
    redcard_version "1.9.9"
    expect { require 'redcard/1.9' }.not_to raise_error
  end

  it "succeeds if RUBY_VERSION is 1.10.0" do
    redcard_version "1.10.0"
    expect { require 'redcard/1.9' }.not_to raise_error
  end

  it "succeeds if RUBY_VERSION is 2.0.0" do
    redcard_version "2.0.0"
    expect { require 'redcard/1.9' }.not_to raise_error
  end

  it "raises an InvalidRubyVersionError if RUBY_VERSION is less than 1.9" do
    redcard_version "1.8.9"
    expect { require 'redcard/1.9' }.to raise_error(RedCard::InvalidRubyVersionError)
  end
end
