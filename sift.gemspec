$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "sift/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "procore-sift"
  s.version     = Sift::VERSION
  s.authors     = ["Procore Technologies"]
  s.email       = ["dev@procore.com"]
  s.homepage    = "https://github.com/procore/sift"
  s.summary     = "Build dynamic filters and sorts for Rails and Active Record"
  s.description = "A declarative DSL for building filters and sorts with Rails and Active Record"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*",
                "MIT-LICENSE",
                "Rakefile",
                "README.md"]

  s.required_ruby_version = ">= 2.7.0"

  s.add_dependency "activerecord", ">= 7.0"

  s.add_development_dependency "pry"
  s.add_development_dependency "rails", ">= 7.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubocop", "~> 1.68"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "appraisal"
end
