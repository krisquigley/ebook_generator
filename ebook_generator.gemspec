$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ebook_generator/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'ebook_generator'
  s.version     = EbookGenerator::VERSION
  s.summary     = "Generates eBooks"
  s.description = "A simple eBook (ePub and Mobi) generator gem"
  s.authors     = "Kris Quigley"
  s.email       = 'info@affinity-tech.com'
  s.homepage    = 'http://www.affinity-tech.com'
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4"
  s.add_dependency 'redcarpet',  '>= 3.0.0'
  s.add_dependency 'rubyzip',  '>= 1.0.0'
  s.add_dependency 'friendly_id', '~> 5'
  s.add_dependency 'nokogiri'

  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "rspec-rails", "~> 3.0"
  s.add_development_dependency "factory_girl_rails", "~> 4.4"
  s.add_development_dependency 'faker', "~> 1.4"

  s.test_files = Dir["spec/**/*"]
end
