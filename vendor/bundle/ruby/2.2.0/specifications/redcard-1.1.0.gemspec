# -*- encoding: utf-8 -*-
# stub: redcard 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "redcard"
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Brian Shirai"]
  s.date = "2013-03-23"
  s.email = ["brixen@gmail.com"]
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.files = ["LICENSE", "README.md"]
  s.homepage = "https://github.com/brixen/redcard"
  s.rdoc_options = ["--title", "RedCard Gem", "--main", "README", "--line-numbers"]
  s.rubygems_version = "2.4.8"
  s.summary = "RedCard provides a standard way to ensure that the running Ruby implementation matches the desired language version, implementation, and implementation version."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8"])
    else
      s.add_dependency(%q<rake>, ["~> 0.9"])
      s.add_dependency(%q<rspec>, ["~> 2.8"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 0.9"])
    s.add_dependency(%q<rspec>, ["~> 2.8"])
  end
end
