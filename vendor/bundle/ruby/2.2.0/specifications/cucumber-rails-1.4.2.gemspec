# -*- encoding: utf-8 -*-
# stub: cucumber-rails 1.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "cucumber-rails"
  s.version = "1.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Aslak Helles\u{f8}y", "Dennis Bl\u{f6}te", "Rob Holland"]
  s.date = "2014-10-09"
  s.description = "Cucumber Generator and Runtime for Rails"
  s.email = "cukes@googlegroups.com"
  s.homepage = "http://cukes.info"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "cucumber-rails-1.4.2"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capybara>, ["< 3", ">= 1.1.2"])
      s.add_runtime_dependency(%q<cucumber>, ["< 2", ">= 1.3.8"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.5"])
      s.add_runtime_dependency(%q<rails>, ["< 5", ">= 3"])
      s.add_runtime_dependency(%q<mime-types>, ["< 3", ">= 1.16"])
      s.add_development_dependency(%q<ammeter>, ["< 2", ">= 0.2.9"])
      s.add_development_dependency(%q<appraisal>, [">= 0.5.1"])
      s.add_development_dependency(%q<aruba>, [">= 0.4.11"])
      s.add_development_dependency(%q<builder>, ["< 4", ">= 2.1.2"])
      s.add_development_dependency(%q<bundler>, [">= 1.3.5"])
      s.add_development_dependency(%q<database_cleaner>, [">= 0.7.2"])
      s.add_development_dependency(%q<factory_girl>, [">= 3.2"])
      s.add_development_dependency(%q<rake>, [">= 0.9.2.2"])
      s.add_development_dependency(%q<rspec>, ["<= 3.1", ">= 2.2"])
      s.add_development_dependency(%q<bcat>, [">= 0.6.2"])
      s.add_development_dependency(%q<rdiscount>, [">= 2.0.7"])
      s.add_development_dependency(%q<rdoc>, [">= 3.4"])
      s.add_development_dependency(%q<yard>, [">= 0.8.7"])
    else
      s.add_dependency(%q<capybara>, ["< 3", ">= 1.1.2"])
      s.add_dependency(%q<cucumber>, ["< 2", ">= 1.3.8"])
      s.add_dependency(%q<nokogiri>, ["~> 1.5"])
      s.add_dependency(%q<rails>, ["< 5", ">= 3"])
      s.add_dependency(%q<mime-types>, ["< 3", ">= 1.16"])
      s.add_dependency(%q<ammeter>, ["< 2", ">= 0.2.9"])
      s.add_dependency(%q<appraisal>, [">= 0.5.1"])
      s.add_dependency(%q<aruba>, [">= 0.4.11"])
      s.add_dependency(%q<builder>, ["< 4", ">= 2.1.2"])
      s.add_dependency(%q<bundler>, [">= 1.3.5"])
      s.add_dependency(%q<database_cleaner>, [">= 0.7.2"])
      s.add_dependency(%q<factory_girl>, [">= 3.2"])
      s.add_dependency(%q<rake>, [">= 0.9.2.2"])
      s.add_dependency(%q<rspec>, ["<= 3.1", ">= 2.2"])
      s.add_dependency(%q<bcat>, [">= 0.6.2"])
      s.add_dependency(%q<rdiscount>, [">= 2.0.7"])
      s.add_dependency(%q<rdoc>, [">= 3.4"])
      s.add_dependency(%q<yard>, [">= 0.8.7"])
    end
  else
    s.add_dependency(%q<capybara>, ["< 3", ">= 1.1.2"])
    s.add_dependency(%q<cucumber>, ["< 2", ">= 1.3.8"])
    s.add_dependency(%q<nokogiri>, ["~> 1.5"])
    s.add_dependency(%q<rails>, ["< 5", ">= 3"])
    s.add_dependency(%q<mime-types>, ["< 3", ">= 1.16"])
    s.add_dependency(%q<ammeter>, ["< 2", ">= 0.2.9"])
    s.add_dependency(%q<appraisal>, [">= 0.5.1"])
    s.add_dependency(%q<aruba>, [">= 0.4.11"])
    s.add_dependency(%q<builder>, ["< 4", ">= 2.1.2"])
    s.add_dependency(%q<bundler>, [">= 1.3.5"])
    s.add_dependency(%q<database_cleaner>, [">= 0.7.2"])
    s.add_dependency(%q<factory_girl>, [">= 3.2"])
    s.add_dependency(%q<rake>, [">= 0.9.2.2"])
    s.add_dependency(%q<rspec>, ["<= 3.1", ">= 2.2"])
    s.add_dependency(%q<bcat>, [">= 0.6.2"])
    s.add_dependency(%q<rdiscount>, [">= 2.0.7"])
    s.add_dependency(%q<rdoc>, [">= 3.4"])
    s.add_dependency(%q<yard>, [">= 0.8.7"])
  end
end
