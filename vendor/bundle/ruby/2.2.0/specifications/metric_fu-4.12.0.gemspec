# -*- encoding: utf-8 -*-
# stub: metric_fu 4.12.0 ruby lib

Gem::Specification.new do |s|
  s.name = "metric_fu"
  s.version = "4.12.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jake Scruggs", "Sean Soper", "Andre Arko", "Petrik de Heus", "Grant McInnes", "Nick Quaranto", "\u{c9}douard Bri\u{e8}re", "Carl Youngblood", "Richard Huang", "Dan Mayer", "Benjamin Fleischer", "Robin Curry"]
  s.cert_chain = ["certs/bf4.pem"]
  s.date = "2015-06-18"
  s.description = "Code metrics from Flog, Flay, Saikuro, Churn, Reek, Roodi, Code Statistics, and Rails Best Practices. (and optionally RCov)"
  s.email = "github@benjaminfleischer.com"
  s.executables = ["metric_fu", "mf-cane", "mf-churn", "mf-flay", "mf-reek", "mf-roodi", "mf-saikuro"]
  s.extra_rdoc_files = ["HISTORY.md", "CONTRIBUTING.md", "TODO.md", "MIT-LICENSE"]
  s.files = ["CONTRIBUTING.md", "HISTORY.md", "MIT-LICENSE", "TODO.md", "bin/metric_fu", "bin/mf-cane", "bin/mf-churn", "bin/mf-flay", "bin/mf-reek", "bin/mf-roodi", "bin/mf-saikuro"]
  s.homepage = "https://github.com/metricfu/metric_fu"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.md"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.0")
  s.rubyforge_project = "metric_fu"
  s.rubygems_version = "2.4.8"
  s.summary = "A fistful of code metrics, with awesome templates and graphs"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<flay>, [">= 2.0.1", "~> 2.1"])
      s.add_runtime_dependency(%q<churn>, ["~> 0.0.35"])
      s.add_runtime_dependency(%q<flog>, [">= 4.1.1", "~> 4.1"])
      s.add_runtime_dependency(%q<reek>, ["< 3.0", ">= 1.3.4"])
      s.add_runtime_dependency(%q<cane>, [">= 2.5.2", "~> 2.5"])
      s.add_runtime_dependency(%q<rails_best_practices>, [">= 1.14.3", "~> 1.14"])
      s.add_runtime_dependency(%q<metric_fu-Saikuro>, [">= 1.1.3", "~> 1.1"])
      s.add_runtime_dependency(%q<roodi>, ["~> 3.1"])
      s.add_runtime_dependency(%q<code_metrics>, ["~> 0.1"])
      s.add_runtime_dependency(%q<redcard>, [">= 0"])
      s.add_runtime_dependency(%q<coderay>, [">= 0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_runtime_dependency(%q<launchy>, ["~> 2.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1"])
      s.add_development_dependency(%q<test_construct>, [">= 0"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.9"])
    else
      s.add_dependency(%q<flay>, [">= 2.0.1", "~> 2.1"])
      s.add_dependency(%q<churn>, ["~> 0.0.35"])
      s.add_dependency(%q<flog>, [">= 4.1.1", "~> 4.1"])
      s.add_dependency(%q<reek>, ["< 3.0", ">= 1.3.4"])
      s.add_dependency(%q<cane>, [">= 2.5.2", "~> 2.5"])
      s.add_dependency(%q<rails_best_practices>, [">= 1.14.3", "~> 1.14"])
      s.add_dependency(%q<metric_fu-Saikuro>, [">= 1.1.3", "~> 1.1"])
      s.add_dependency(%q<roodi>, ["~> 3.1"])
      s.add_dependency(%q<code_metrics>, ["~> 0.1"])
      s.add_dependency(%q<redcard>, [">= 0"])
      s.add_dependency(%q<coderay>, [">= 0"])
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<launchy>, ["~> 2.0"])
      s.add_dependency(%q<rspec>, ["~> 3.1"])
      s.add_dependency(%q<test_construct>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<simplecov>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<flay>, [">= 2.0.1", "~> 2.1"])
    s.add_dependency(%q<churn>, ["~> 0.0.35"])
    s.add_dependency(%q<flog>, [">= 4.1.1", "~> 4.1"])
    s.add_dependency(%q<reek>, ["< 3.0", ">= 1.3.4"])
    s.add_dependency(%q<cane>, [">= 2.5.2", "~> 2.5"])
    s.add_dependency(%q<rails_best_practices>, [">= 1.14.3", "~> 1.14"])
    s.add_dependency(%q<metric_fu-Saikuro>, [">= 1.1.3", "~> 1.1"])
    s.add_dependency(%q<roodi>, ["~> 3.1"])
    s.add_dependency(%q<code_metrics>, ["~> 0.1"])
    s.add_dependency(%q<redcard>, [">= 0"])
    s.add_dependency(%q<coderay>, [">= 0"])
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<launchy>, ["~> 2.0"])
    s.add_dependency(%q<rspec>, ["~> 3.1"])
    s.add_dependency(%q<test_construct>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<simplecov>, ["~> 0.9"])
  end
end
