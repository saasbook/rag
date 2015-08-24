require 'spec_helper'

describe "Rubinius version requirement" do
  before do
    redcard_save_state
    redcard_unload "redcard/rubinius/2.0"
  end

  after do
    redcard_restore_state
  end

  it "succeeds if RUBY_ENGINE is 'rbx' and Rubinius::VERSION is greater than or equal to 2.0" do
    redcard_engine_version "rbx", "2.0.0"
    expect { require 'redcard/rubinius/2.0' }.not_to raise_error
  end

  it "raises an InvalidRubyEngineError if RUBY_ENGINE is 'topaz'" do
    redcard_engine_version "topaz", "2.0.0"
    expect { require 'redcard/rubinius/2.0' }.to raise_error(RedCard::InvalidRubyError)
  end

  it "raises an InvalidEngineVersionError if Rubinius::VERSION is less than 2.0" do
    redcard_engine_version "rbx", "1.2.4"
    expect { require 'redcard/rubinius/2.0' }.to raise_error(RedCard::InvalidRubyError)
  end
end
