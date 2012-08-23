$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_bookmark/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_bookmark"
  s.version     = EnjuBookmark::VERSION
  s.authors     = ["Kosuke Tanabe"]
  s.email       = ["tanabe@mwr.mediacom.keio.ac.jp"]
  s.homepage    = "https://github.com/nabeta/enju_bookmark.git"
  s.summary     = "enju_bookmark plugin"
  s.description = "Purchase request management for Next-L Enju"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "acts-as-taggable-on", "~> 2.3"
  s.add_dependency "state_machine"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "enju_biblio", "~> 0.1.0.pre5"
  s.add_development_dependency "enju_library", "~> 0.1.0.pre3"
  s.add_development_dependency "enju_circulation", "~> 0.1.0.pre4"
  s.add_development_dependency "enju_manifestation_viewer"
  s.add_development_dependency "sunspot_solr", "~> 2.0.0.pre.120720"
end
