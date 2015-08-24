# -*- encoding: utf-8 -*-
# stub: adamantium 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "adamantium"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Dan Kubb", "Markus Schirp"]
  s.date = "2014-01-21"
  s.description = "Immutable extensions to objects"
  s.email = ["dan.kubb@gmail.com", "mbj@seonic.net"]
  s.extra_rdoc_files = ["LICENSE", "README.md", "CONTRIBUTING.md", "TODO"]
  s.files = ["CONTRIBUTING.md", "LICENSE", "README.md", "TODO"]
  s.homepage = "https://github.com/dkubb/adamantium"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Immutable extensions to objects"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ice_nine>, ["~> 0.11.0"])
      s.add_runtime_dependency(%q<memoizable>, ["~> 0.4.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.5.2", "~> 1.5"])
    else
      s.add_dependency(%q<ice_nine>, ["~> 0.11.0"])
      s.add_dependency(%q<memoizable>, ["~> 0.4.0"])
      s.add_dependency(%q<bundler>, [">= 1.5.2", "~> 1.5"])
    end
  else
    s.add_dependency(%q<ice_nine>, ["~> 0.11.0"])
    s.add_dependency(%q<memoizable>, ["~> 0.4.0"])
    s.add_dependency(%q<bundler>, [">= 1.5.2", "~> 1.5"])
  end
end
