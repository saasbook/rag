# -*- encoding: utf-8 -*-
# stub: fakeweb 1.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "fakeweb"
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Chris Kampmeier", "Blaine Cook"]
  s.date = "2010-08-22"
  s.description = "FakeWeb is a helper for faking web requests in Ruby. It works at a global level, without modifying code or writing extensive stubs."
  s.email = ["chris@kampers.net", "romeda@gmail.com"]
  s.extra_rdoc_files = ["LICENSE.txt", "README.rdoc"]
  s.files = ["LICENSE.txt", "README.rdoc"]
  s.homepage = "http://github.com/chrisk/fakeweb"
  s.rdoc_options = ["--charset=UTF-8"]
  s.rubyforge_project = "fakeweb"
  s.rubygems_version = "2.4.8"
  s.summary = "A tool for faking responses to HTTP requests"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<mocha>, [">= 0.9.5"])
    else
      s.add_dependency(%q<mocha>, [">= 0.9.5"])
    end
  else
    s.add_dependency(%q<mocha>, [">= 0.9.5"])
  end
end
