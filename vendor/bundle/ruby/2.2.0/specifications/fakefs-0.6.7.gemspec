# -*- encoding: utf-8 -*-
# stub: fakefs 0.6.7 ruby lib

Gem::Specification.new do |s|
  s.name = "fakefs"
  s.version = "0.6.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Chris Wanstrath", "Scott Taylor", "Jeff Hodges", "Pat Nakajima", "Brian Donovan"]
  s.date = "2015-02-15"
  s.description = "A fake filesystem. Use it in your tests."
  s.email = ["chris@ozmm.org"]
  s.homepage = "http://github.com/defunkt/fakefs"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "A fake filesystem. Use it in your tests."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, ["~> 10.3"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.25"])
      s.add_development_dependency(%q<minitest>, ["~> 5.5"])
      s.add_development_dependency(%q<minitest-rg>, ["~> 5.1"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, ["~> 10.3"])
      s.add_dependency(%q<rspec>, ["~> 3.1"])
      s.add_dependency(%q<rubocop>, ["~> 0.25"])
      s.add_dependency(%q<minitest>, ["~> 5.5"])
      s.add_dependency(%q<minitest-rg>, ["~> 5.1"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, ["~> 10.3"])
    s.add_dependency(%q<rspec>, ["~> 3.1"])
    s.add_dependency(%q<rubocop>, ["~> 0.25"])
    s.add_dependency(%q<minitest>, ["~> 5.5"])
    s.add_dependency(%q<minitest-rg>, ["~> 5.1"])
  end
end
