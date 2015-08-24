# coding: utf-8
# from https://github.com/vcr/vcr/blob/master/spec/quality_spec.rb
# from https://raw.githubusercontent.com/bundler/bundler/master/spec/quality_spec.rb
require "spec_helper"

if defined?(Encoding) && Encoding.default_external != "UTF-8"
  Encoding.default_external = "UTF-8"
end

RSpec.describe "The library itself" do
  # For some reason RSpec may expect this to be defined
  # and crash really bad without it
  def self.uses_transaction?(*)
    false
  end

  def encode_utf8!(string)
    string.encode!(Encoding::UTF_8,
                   invalid: :replace,
                   undef: :replace,
                   replace: "<?>".freeze
                  )
  end

  def ignore_whitespace?(filename)
    @whitespace_regex ||=
      /\.gitmodules|fixtures|vendor|LICENSE|etc|db|public|reports/
    !!(filename =~ @whitespace_regex)
  end

  def check_for_spec_defs_with_single_quotes(filename)
    failing_lines = []

    File.readlines(filename).each_with_index do |line, number|
      encode_utf8!(line)
      failing_lines << number + 1 if line =~ /^ *(describe|it|context) {1}'{1}/
    end

    if failing_lines.any?
      # Prevent rubocop from looping infinitely
      # rubocop:disable Style/StringLiterals
      "#{filename} uses inconsistent single quotes "\
      "on lines #{failing_lines.join(', ')}"
      # rubocop:enable Style/StringLiterals
    end
  end

  def check_for_tab_characters(filename)
    failing_lines = []
    File.readlines(filename).each_with_index do |line, number|
      encode_utf8!(line)
      failing_lines << number + 1 if line =~ /\t/
    end

    unless failing_lines.empty?
      # Prevent rubocop from looping infinitely
      # rubocop:disable Style/StringLiterals
      "#{filename} has tab characters on lines #{failing_lines.join(', ')}"
      # rubocop:enable Style/StringLiterals
    end
  end

  def check_for_extra_spaces(filename)
    failing_lines = []
    File.readlines(filename).each_with_index do |line, number|
      encode_utf8!(line)
      next if line =~ /^\s+#.*\s+\n$/
      failing_lines << number + 1 if line =~ /\s+\n$/
    end

    unless failing_lines.empty?
      # Prevent rubocop from looping infinitely
      # rubocop:disable Style/StringLiterals
      "#{filename} has spaces on the EOL on lines #{failing_lines.join(', ')}"
      # rubocop:enable Style/StringLiterals
    end
  end

  RSpec::Matchers.define :be_well_formed do
    failure_message do |actual|
      actual.join("\n")
    end

    match(&:empty?)
  end

  it "has no malformed whitespace" do
    error_messages = []
    Dir.chdir(File.expand_path("../..", __FILE__)) do
      `git ls-files -z`.split("\x0").each do |filename|
        next if !File.exist?(filename)
        next if ignore_whitespace?(filename)
        error_messages << check_for_tab_characters(filename)
        error_messages << check_for_extra_spaces(filename)
      end
    end
    expect(error_messages.compact).to be_well_formed
  end

  it "uses double-quotes consistently in specs" do
    included = /spec/
    error_messages = []
    Dir.chdir(File.expand_path("../", __FILE__)) do
      `git ls-files -z spec`.split("\x0").each do |filename|
        next unless filename =~ included
        error_messages << check_for_spec_defs_with_single_quotes(filename)
      end
    end
    error_messages.compact.each do |error_message|
      warn error_message
    end
    expect(error_messages.compact).to be_well_formed
  end
end
