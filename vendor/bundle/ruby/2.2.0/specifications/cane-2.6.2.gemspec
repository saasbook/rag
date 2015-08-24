# -*- encoding: utf-8 -*-
# stub: cane 2.6.2 ruby lib

Gem::Specification.new do |s|
  s.name = "cane"
  s.version = "2.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Xavier Shay"]
  s.date = "2014-04-21"
  s.description = "Fails your build if code quality thresholds are not met"
  s.email = ["xavier@squareup.com"]
  s.executables = ["cane"]
  s.files = ["bin/cane"]
  s.homepage = "http://github.com/square/cane"
  s.licenses = ["Apache 2.0"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.0")
  s.rubygems_version = "2.4.8"
  s.summary = "Fails your build if code quality thresholds are not met. Provides complexity and style checkers built-in, and allows integration with with custom quality metrics."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<parallel>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<rspec-fire>, [">= 0"])
    else
      s.add_dependency(%q<parallel>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<rspec-fire>, [">= 0"])
    end
  else
    s.add_dependency(%q<parallel>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<rspec-fire>, [">= 0"])
  end
end
