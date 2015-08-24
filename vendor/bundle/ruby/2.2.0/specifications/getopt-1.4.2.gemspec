# -*- encoding: utf-8 -*-
# stub: getopt 1.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "getopt"
  s.version = "1.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Daniel J. Berger"]
  s.date = "2014-10-13"
  s.description = "    The getopt library provides two different command line option parsers.\n    They are meant as easier and more convenient replacements for the\n    command line parsers that ship as part of the Ruby standard library.\n    Please see the README for additional comments.\n"
  s.email = "djberg96@gmail.com"
  s.extra_rdoc_files = ["README", "CHANGES", "MANIFEST"]
  s.files = ["CHANGES", "MANIFEST", "README"]
  s.homepage = "https://github.com/djberg96/getopt"
  s.licenses = ["Artistic 2.0"]
  s.rubygems_version = "2.4.8"
  s.summary = "Getopt::Std and Getopt::Long option parsers for Ruby"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<test-unit>, [">= 2.5.0"])
    else
      s.add_dependency(%q<test-unit>, [">= 2.5.0"])
    end
  else
    s.add_dependency(%q<test-unit>, [">= 2.5.0"])
  end
end
