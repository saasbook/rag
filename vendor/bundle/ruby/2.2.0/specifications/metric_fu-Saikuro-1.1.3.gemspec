# -*- encoding: utf-8 -*-
# stub: metric_fu-Saikuro 1.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "metric_fu-Saikuro"
  s.version = "1.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Zev Blut", "David Barri"]
  s.date = "2014-01-21"
  s.description = "When given Ruby\n  source code Saikuro will generate a report listing the cyclomatic\n  complexity of each method found.  In addition, Saikuro counts the\n  number of lines per method and can generate a listing of the number of\n  tokens on each line of code."
  s.email = ["zb@ubit.com", "japgolly@gmail.com"]
  s.executables = ["saikuro"]
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "bin/saikuro"]
  s.homepage = "https://github.com/metricfu/Saikuro"
  s.licenses = ["BSD"]
  s.rubyforge_project = "Saikuro"
  s.rubygems_version = "2.4.8"
  s.summary = "Saikuro is a Ruby cyclomatic complexity analyzer."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version
end
