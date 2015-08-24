# -*- encoding: utf-8 -*-
# stub: concord 0.1.5 ruby lib

Gem::Specification.new do |s|
  s.name = "concord"
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Markus Schirp"]
  s.date = "2014-04-20"
  s.description = "Helper for object composition"
  s.email = ["mbj@schirp-dso.com"]
  s.homepage = "https://github.com/mbj/concord"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.8"
  s.summary = "Helper for object composition"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<adamantium>, ["~> 0.2.0"])
      s.add_runtime_dependency(%q<equalizer>, ["~> 0.0.9"])
    else
      s.add_dependency(%q<adamantium>, ["~> 0.2.0"])
      s.add_dependency(%q<equalizer>, ["~> 0.0.9"])
    end
  else
    s.add_dependency(%q<adamantium>, ["~> 0.2.0"])
    s.add_dependency(%q<equalizer>, ["~> 0.0.9"])
  end
end
