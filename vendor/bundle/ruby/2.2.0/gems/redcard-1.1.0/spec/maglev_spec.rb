require 'spec_helper'

describe "Ruby engine requirement" do
  before do
    redcard_save_state
    redcard_unload "redcard/maglev"
  end

  after do
    redcard_restore_state
  end

  it "succeeds if RUBY_ENGINE is 'maglev'" do
    redcard_engine_version "maglev", "1.0.0"
    expect { require 'redcard/maglev' }.not_to raise_error
  end

  it "raises an InvalidRubyEngineError if RUBY_ENGINE is 'topaz'" do
    redcard_engine_version "topaz", "1.0.0"
    expect { require 'redcard/maglev' }.to raise_error(RedCard::InvalidRubyEngineError)
  end

  it "raises an InvalidRubyEngineError if RUBY_ENGINE is 'rbx'" do
    redcard_engine_version "rbx", "1.0.0"
    expect { require 'redcard/maglev' }.to raise_error(RedCard::InvalidRubyEngineError)
  end
end
