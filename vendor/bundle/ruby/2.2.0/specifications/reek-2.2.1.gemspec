# -*- encoding: utf-8 -*-
# stub: reek 2.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "reek"
  s.version = "2.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Kevin Rutherford", "Timo Roessner", "Matijs van Zuijlen"]
  s.date = "2015-05-11"
  s.description = "    Reek is a tool that examines Ruby classes, modules and methods and reports\n    any code smells it finds.\n"
  s.email = ["timo.roessner@googlemail.com"]
  s.executables = ["reek"]
  s.extra_rdoc_files = ["CHANGELOG", "License.txt"]
  s.files = ["CHANGELOG", "License.txt", "bin/reek"]
  s.homepage = "https://github.com/troessner/reek/wiki"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.md", "-x", "assets/|bin/|config/|features/|spec/|tasks/"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.8"
  s.summary = "Code smell detector for Ruby"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<parser>, ["~> 2.2"])
      s.add_runtime_dependency(%q<rainbow>, ["~> 2.0"])
      s.add_runtime_dependency(%q<unparser>, ["~> 0.2.2"])
      s.add_development_dependency(%q<activesupport>, ["~> 4.2"])
      s.add_development_dependency(%q<aruba>, ["~> 0.6.2"])
      s.add_development_dependency(%q<bundler>, ["~> 1.1"])
      s.add_development_dependency(%q<cucumber>, ["~> 2.0"])
      s.add_development_dependency(%q<factory_girl>, ["~> 4.0"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.30.0"])
      s.add_development_dependency(%q<yard>, ["~> 0.8.7"])
    else
      s.add_dependency(%q<parser>, ["~> 2.2"])
      s.add_dependency(%q<rainbow>, ["~> 2.0"])
      s.add_dependency(%q<unparser>, ["~> 0.2.2"])
      s.add_dependency(%q<activesupport>, ["~> 4.2"])
      s.add_dependency(%q<aruba>, ["~> 0.6.2"])
      s.add_dependency(%q<bundler>, ["~> 1.1"])
      s.add_dependency(%q<cucumber>, ["~> 2.0"])
      s.add_dependency(%q<factory_girl>, ["~> 4.0"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<rubocop>, ["~> 0.30.0"])
      s.add_dependency(%q<yard>, ["~> 0.8.7"])
    end
  else
    s.add_dependency(%q<parser>, ["~> 2.2"])
    s.add_dependency(%q<rainbow>, ["~> 2.0"])
    s.add_dependency(%q<unparser>, ["~> 0.2.2"])
    s.add_dependency(%q<activesupport>, ["~> 4.2"])
    s.add_dependency(%q<aruba>, ["~> 0.6.2"])
    s.add_dependency(%q<bundler>, ["~> 1.1"])
    s.add_dependency(%q<cucumber>, ["~> 2.0"])
    s.add_dependency(%q<factory_girl>, ["~> 4.0"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<rubocop>, ["~> 0.30.0"])
    s.add_dependency(%q<yard>, ["~> 0.8.7"])
  end
end
