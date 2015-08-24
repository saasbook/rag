require 'redcard/version'
require 'redcard/engine'

class RedCard
  class InvalidRubyVersionError < Exception; end
  class InvalidRubyEngineError < Exception; end
  class UnknownRubyEngineError < Exception; end
  class InvalidRubyError < Exception; end

  def self.check(*requirements)
    new(*requirements).check
  end

  def self.verify(*requirements)
    card = new(*requirements)
    unless card.check
      raise card.error, card.message
    end
  end

  def self.engine
    (defined?(RUBY_ENGINE) && RUBY_ENGINE) || "ruby"
  end

  def self.engine_version
    case engine
    # when "ironruby"
      # TODO
    when "jruby"
      Object.const_get :JRUBY_VERSION
    when "maglev"
      Object.const_get :MAGLEV_VERSION
    when "rbx"
      if defined?(::Rubinius)
        Object.const_get(:Rubinius).const_get(:VERSION)
      end
    when "ruby"
      RUBY_VERSION
    when "topaz"
      if defined?(::Topaz)
        Object.const_get(:Topaz).const_get(:VERSION)
      end
    else
      raise UnknownRubyEngineError, "#{engine} is not recognized"
    end
  end


  attr_reader :error, :message

  def initialize(*requirements)
    @engine_versions = requirements.last.kind_of?(Hash) ? requirements.pop.to_a : []
    @engines = requirements.select { |x| x.kind_of? Symbol }
    @versions = requirements.select { |x| x.kind_of? String or x.kind_of? Range }
  end

  def check
    unless @engines.empty? or
           @engines.any? { |x| Engine.new(RedCard.engine, x).valid? }
      invalid_engine
      return false
    end

    unless @versions.empty? or
           @versions.any? { |x| Version.new(RUBY_VERSION, x).valid? }
      invalid_ruby_version
      return false
    end

    return true if @engine_versions.empty?

    @engine_versions.map! do |e, v|
      [Engine.new(RedCard.engine, e), Version.new(RedCard.engine_version, v)]
    end

    return true if @engine_versions.any? do |engine, version|
      engine.valid? and version.valid?
    end

    invalid_engine_version
    return false
  end

  private

  def invalid_ruby_version
    @error = InvalidRubyVersionError
    @message = "#{RUBY_VERSION} is not supported"
  end

  def invalid_engine
    @error = InvalidRubyEngineError
    @message = "#{RedCard.engine} is not supported"
  end

  def invalid_engine_version
    @error = InvalidRubyError
    @message = "#{RedCard.engine} version #{RedCard.engine_version} is not supported"
  end
end
