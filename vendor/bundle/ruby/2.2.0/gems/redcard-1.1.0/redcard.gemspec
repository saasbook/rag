# -*- encoding: utf-8 -*-
require 'redcard/version'

Gem::Specification.new do |gem|
  gem.name          = "redcard"
  gem.version       = "#{RedCard::VERSION}"
  gem.authors       = ["Brian Shirai"]
  gem.email         = ["brixen@gmail.com"]
  gem.homepage      = "https://github.com/brixen/redcard"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) unless File.extname(f) == ".bat" }.compact
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
  gem.summary       = <<-EOS
RedCard provides a standard way to ensure that the running Ruby implementation
matches the desired language version, implementation, and implementation
version.
                      EOS
  gem.has_rdoc          = true
  gem.extra_rdoc_files  = %w[ README.md LICENSE ]
  gem.rubygems_version  = %q{1.3.5}

  gem.rdoc_options  << '--title' << 'RedCard Gem' <<
                    '--main' << 'README' <<
                    '--line-numbers'

  gem.add_development_dependency "rake",   "~> 0.9"
  gem.add_development_dependency "rspec",  "~> 2.8"
end

