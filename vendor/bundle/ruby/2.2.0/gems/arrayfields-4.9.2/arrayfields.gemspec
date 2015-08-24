## arrayfields.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "arrayfields"
  spec.version = "4.9.2"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "arrayfields"
  spec.description = "string/symbol keyword access to arrays"
  spec.license = "same as ruby's"

  spec.files =
["LICENSE",
 "README",
 "Rakefile",
 "arrayfields.gemspec",
 "install.rb",
 "lib",
 "lib/arrayfields.rb",
 "readme.rb",
 "sample",
 "sample/a.rb",
 "sample/b.rb",
 "sample/c.rb",
 "sample/d.rb",
 "sample/e.rb",
 "test",
 "test/arrayfields.rb",
 "test/memtest.rb"]

  spec.executables = []
  
  spec.require_path = "lib"

  spec.test_files = "test/arrayfields.rb"

  

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "https://github.com/ahoward/arrayfields"
end
