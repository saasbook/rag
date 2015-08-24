require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include("**/*.gem", "**/*.rbc")

namespace :gem do
  desc "Create the getopt gem"
  task :create => [:clean] do
    spec = eval(IO.read('getopt.gemspec'))
    if Gem::VERSION < "2.0"
      Gem::Builder.new(spec).build
    else
      require 'rubygems/package'
      Gem::Package.build(spec)
    end
  end

  desc "Install the getopt gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

Rake::TestTask.new do |t|
  t.warning = true
  t.verbose = true
end

namespace :test do
  Rake::TestTask.new('getopt_long') do |t|
    t.test_files = 'test/test_getopt_long.rb'
    t.warning = true
    t.verbose = true
  end

  Rake::TestTask.new('getopt_std') do |t|
    t.test_files = 'test/test_getopt_std.rb'
    t.warning = true
    t.verbose = true
  end
end

task :default => :test
