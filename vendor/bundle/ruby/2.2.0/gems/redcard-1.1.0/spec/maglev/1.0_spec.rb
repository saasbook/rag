require 'spec_helper'

describe "MagLev version requirement" do
  before do
    redcard_save_state
    redcard_unload "redcard/maglev/1.0"
  end

  after do
    redcard_restore_state
  end

  it "succeeds if RUBY_ENGINE is 'maglev' and MAGLEV_VERSION is greater than or equal to 1.0" do
    redcard_version "1.8.7"
    redcard_engine_version "maglev", "1.0.0"
    expect { require 'redcard/maglev/1.0' }.not_to raise_error
  end

  it "raises an InvalidRubyEngineError if RUBY_ENGINE is 'topaz'" do
    redcard_version "1.8.7"
    redcard_engine_version "topaz", "1.0.0"
    expect { require 'redcard/maglev/1.0' }.to raise_error(RedCard::InvalidRubyError)
  end

  it "raises an InvalidRubyEngineError if RUBY_ENGINE is 'rbx'" do
    redcard_version "1.8.7"
    redcard_engine_version "rbx", "1.0.0"
    expect { require 'redcard/maglev/1.0' }.to raise_error(RedCard::InvalidRubyError)
  end

end

describe "MagLev's Ruby-version dependency" do

  before do
    redcard_save_state
    redcard_unload "redcard/1.8"
    redcard_unload "redcard/1.9"
    redcard_unload "redcard/maglev/1.0"
  end

  after do
    redcard_restore_state
  end

  it "succeeds if MAGLEV_VERSION is 1.0 and RUBY_VERSION is not greater than 1.8" do
    redcard_version "1.8.7"
    redcard_engine_version "maglev", "1.0.0"
    expect { require 'redcard/maglev/1.0' }.not_to raise_error
 end

  it "raises an InvalidRubyVersionError if MAGLEV_VERSION is 1.0 and RUBY_VERSION is greater than 1.8" do
    redcard_version "1.9.3"
    redcard_engine_version "maglev", "1.0.0"
    expect { require 'redcard/maglev/1.0' }.to raise_error(RedCard::InvalidRubyVersionError)
 end

end
