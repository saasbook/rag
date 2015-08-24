# -*- encoding: utf-8 -*-
# stub: code_metrics 0.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "code_metrics"
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.7") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["David Heinemeier Hansson", "Benjamin Fleischer"]
  s.date = "2013-12-31"
  s.description = "rake stats is great for looking at statistics on your code, displaying things like KLOCs (thousands of lines of code) and your code to test ratio."
  s.email = ["david@loudthinking.com", "github@benjaminfleischer.com"]
  s.executables = ["code_metrics", "code_metrics-profile"]
  s.files = ["bin/code_metrics", "bin/code_metrics-profile"]
  s.homepage = "https://github.com/bf4/code_metrics"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.0")
  s.rubygems_version = "2.4.8"
  s.summary = "Extraction of the rails rake stats task as a gem and rails plugin"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rails>, ["< 5.0", "> 3.0"])
    else
      s.add_dependency(%q<rails>, ["< 5.0", "> 3.0"])
    end
  else
    s.add_dependency(%q<rails>, ["< 5.0", "> 3.0"])
  end
end
