# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "webrobots/version"

Gem::Specification.new do |s|
  s.name        = "webrobots"
  s.version     = Webrobots::VERSION
  s.authors     = ["Akinori MUSHA"]
  s.email       = ["knu@idaemons.org"]
  s.homepage    = %q{https://github.com/knu/webrobots}
  s.licenses    = [%q{2-clause BSDL}]
  s.summary     = %q{A Ruby library to help write robots.txt compliant web robots}
  s.description = <<-'EOS'
This library helps write robots.txt compliant web robots in Ruby.
  EOS

  s.files         = `git ls-files`.split("\n")
  s.test_files    = s.files.grep(%r{/test_[^/]+\.rb$})
  s.executables   = s.files.grep(%r{^bin/[^.]}).map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.rdoc_options += [
    '--exclude', '\.ry$'
  ]

  s.add_development_dependency("rake", [">= 0.9.2.2"])
  s.add_development_dependency("racc", [">= 0"]) unless RUBY_PLATFORM == "java"
  s.add_development_dependency("shoulda", [">= 0"])
  s.add_development_dependency("rdoc", ["> 2.4.2"])
  s.add_development_dependency("bundler", [">= 1.2"])
  s.add_development_dependency("nokogiri", [">= 1.4.4"])
end
