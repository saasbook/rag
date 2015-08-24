# -*- encoding: utf-8 -*-
# stub: database_cleaner 1.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "database_cleaner"
  s.version = "1.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Ben Mabey"]
  s.date = "2015-01-02"
  s.description = "Strategies for cleaning databases. Can be used to ensure a clean state for testing."
  s.email = "ben@benmabey.com"
  s.extra_rdoc_files = ["LICENSE", "README.markdown", "TODO"]
  s.files = ["LICENSE", "README.markdown", "TODO"]
  s.homepage = "http://github.com/DatabaseCleaner/database_cleaner"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Strategies for cleaning databases.  Can be used to ensure a clean state for testing."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug19>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<json_pure>, [">= 0"])
      s.add_development_dependency(%q<activerecord-mysql2-adapter>, [">= 0"])
      s.add_development_dependency(%q<activerecord>, [">= 0"])
      s.add_development_dependency(%q<datamapper>, [">= 0"])
      s.add_development_dependency(%q<dm-migrations>, [">= 0"])
      s.add_development_dependency(%q<dm-sqlite-adapter>, [">= 0"])
      s.add_development_dependency(%q<mongoid>, [">= 0"])
      s.add_development_dependency(%q<tzinfo>, [">= 0"])
      s.add_development_dependency(%q<mongo_ext>, [">= 0"])
      s.add_development_dependency(%q<bson_ext>, [">= 0"])
      s.add_development_dependency(%q<mongoid-tree>, [">= 0"])
      s.add_development_dependency(%q<mongo_mapper>, [">= 0"])
      s.add_development_dependency(%q<moped>, [">= 0"])
      s.add_development_dependency(%q<neo4j-core>, [">= 0"])
      s.add_development_dependency(%q<couch_potato>, [">= 0"])
      s.add_development_dependency(%q<sequel>, ["~> 3.21.0"])
      s.add_development_dependency(%q<mysql>, ["~> 2.8.1"])
      s.add_development_dependency(%q<mysql2>, [">= 0"])
      s.add_development_dependency(%q<pg>, [">= 0"])
      s.add_development_dependency(%q<ohm>, ["~> 0.1.3"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<ruby-debug19>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<activerecord-mysql2-adapter>, [">= 0"])
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<datamapper>, [">= 0"])
      s.add_dependency(%q<dm-migrations>, [">= 0"])
      s.add_dependency(%q<dm-sqlite-adapter>, [">= 0"])
      s.add_dependency(%q<mongoid>, [">= 0"])
      s.add_dependency(%q<tzinfo>, [">= 0"])
      s.add_dependency(%q<mongo_ext>, [">= 0"])
      s.add_dependency(%q<bson_ext>, [">= 0"])
      s.add_dependency(%q<mongoid-tree>, [">= 0"])
      s.add_dependency(%q<mongo_mapper>, [">= 0"])
      s.add_dependency(%q<moped>, [">= 0"])
      s.add_dependency(%q<neo4j-core>, [">= 0"])
      s.add_dependency(%q<couch_potato>, [">= 0"])
      s.add_dependency(%q<sequel>, ["~> 3.21.0"])
      s.add_dependency(%q<mysql>, ["~> 2.8.1"])
      s.add_dependency(%q<mysql2>, [">= 0"])
      s.add_dependency(%q<pg>, [">= 0"])
      s.add_dependency(%q<ohm>, ["~> 0.1.3"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<ruby-debug19>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<activerecord-mysql2-adapter>, [">= 0"])
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<datamapper>, [">= 0"])
    s.add_dependency(%q<dm-migrations>, [">= 0"])
    s.add_dependency(%q<dm-sqlite-adapter>, [">= 0"])
    s.add_dependency(%q<mongoid>, [">= 0"])
    s.add_dependency(%q<tzinfo>, [">= 0"])
    s.add_dependency(%q<mongo_ext>, [">= 0"])
    s.add_dependency(%q<bson_ext>, [">= 0"])
    s.add_dependency(%q<mongoid-tree>, [">= 0"])
    s.add_dependency(%q<mongo_mapper>, [">= 0"])
    s.add_dependency(%q<moped>, [">= 0"])
    s.add_dependency(%q<neo4j-core>, [">= 0"])
    s.add_dependency(%q<couch_potato>, [">= 0"])
    s.add_dependency(%q<sequel>, ["~> 3.21.0"])
    s.add_dependency(%q<mysql>, ["~> 2.8.1"])
    s.add_dependency(%q<mysql2>, [">= 0"])
    s.add_dependency(%q<pg>, [">= 0"])
    s.add_dependency(%q<ohm>, ["~> 0.1.3"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
  end
end
