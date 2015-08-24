# -*- encoding: utf-8 -*-
# stub: unparser 0.2.4 ruby lib

Gem::Specification.new do |s|
  s.name = "unparser"
  s.version = "0.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Markus Schirp"]
  s.date = "2015-05-30"
  s.description = "Generate equivalent source for parser gem AST nodes"
  s.email = "mbj@schir-dso.com"
  s.executables = ["unparser"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md", "bin/unparser"]
  s.homepage = "http://github.com/mbj/unparser"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.8"
  s.summary = "Generate equivalent source for parser gem AST nodes"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<parser>, ["~> 2.2.2"])
      s.add_runtime_dependency(%q<procto>, ["~> 0.0.2"])
      s.add_runtime_dependency(%q<concord>, ["~> 0.1.5"])
      s.add_runtime_dependency(%q<adamantium>, ["~> 0.2.0"])
      s.add_runtime_dependency(%q<equalizer>, ["~> 0.0.9"])
      s.add_runtime_dependency(%q<abstract_type>, ["~> 0.0.7"])
      s.add_runtime_dependency(%q<diff-lcs>, ["~> 1.2.5"])
    else
      s.add_dependency(%q<parser>, ["~> 2.2.2"])
      s.add_dependency(%q<procto>, ["~> 0.0.2"])
      s.add_dependency(%q<concord>, ["~> 0.1.5"])
      s.add_dependency(%q<adamantium>, ["~> 0.2.0"])
      s.add_dependency(%q<equalizer>, ["~> 0.0.9"])
      s.add_dependency(%q<abstract_type>, ["~> 0.0.7"])
      s.add_dependency(%q<diff-lcs>, ["~> 1.2.5"])
    end
  else
    s.add_dependency(%q<parser>, ["~> 2.2.2"])
    s.add_dependency(%q<procto>, ["~> 0.0.2"])
    s.add_dependency(%q<concord>, ["~> 0.1.5"])
    s.add_dependency(%q<adamantium>, ["~> 0.2.0"])
    s.add_dependency(%q<equalizer>, ["~> 0.0.9"])
    s.add_dependency(%q<abstract_type>, ["~> 0.0.7"])
    s.add_dependency(%q<diff-lcs>, ["~> 1.2.5"])
  end
end
