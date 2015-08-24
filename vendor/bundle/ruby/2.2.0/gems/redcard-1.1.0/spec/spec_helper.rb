require 'redcard'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

class RedCard
  module Specs
    @verbose = nil
    @ruby_version = nil
    @engine = nil
    @engine_version = nil

    def self.save_state
      @verbose = $VERBOSE
      $VERBOSE = nil
      @ruby_version = RUBY_VERSION
      @ruby_engine = RedCard.engine
      @engine_version = RedCard.engine_version
    end

    def self.restore_state
      $VERBOSE = nil
      Object.const_set :RUBY_VERSION, @ruby_version

      engine_version = @engine_version
      Object.const_set :RUBY_ENGINE, @ruby_engine

      $VERBOSE = @verbose
    end

    def self.version=(version)
      Object.const_set :RUBY_VERSION, version
    end

    def self.engine=(engine)
      Object.const_set :RUBY_ENGINE, engine
    end

    # When version is nil, we unset the constant for that Ruby engine.
    def self.engine_version=(version)
      case RedCard.engine
      # when "ironruby"
        # TODO
      when "jruby"
        if version
          Object.const_set :JRUBY_VERSION, version
        else
          Object.send :remove_const, :JRUBY_VERSION
        end
      when "maglev"
        if version
          Object.const_set :MAGLEV_VERSION, version
        else
          Object.send :remove_const, :MAGLEV_VERSION
        end
      when "rbx"
        if version
          Object.const_set :Rubinius, Module.new unless defined?(::Rubinius)
          Object.const_get(:Rubinius).const_set(:VERSION, version)
        else
          Object.send :remove_const, :Rubinius
        end
      when "ruby"
        RUBY_VERSION
      when "topaz"
        if version
          Object.const_set :Topaz, Module.new unless defined?(::Topaz)
          Object.const_get(:Topaz).const_set(:VERSION, version)
        else
          Object.send :remove_const, :Topaz
        end
      end
    end
  end
end

def redcard_save_state
  RedCard::Specs.save_state
end

def redcard_restore_state
  RedCard::Specs.restore_state
end

def redcard_unload(path)
  $".delete "#{path}.rb"
  $".delete File.expand_path("../../lib/#{path}.rb", __FILE__)
end

def redcard_version(version)
  RedCard::Specs.version = version
end

def redcard_engine_version(engine, version)
  RedCard::Specs.engine = engine
  RedCard::Specs.engine_version = version
end
