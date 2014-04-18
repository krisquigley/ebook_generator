# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ebook_generator/version"

Gem::Specification.new do |s|
  s.name        = 'ebook_generator'
  s.version     = EbookGenerator::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Generates eBooks"
  s.description = "A simple eBook (ePub) generator gem"
  s.authors     = ["Kris Quigley"]
  s.email       = 'kris@krisquigley.co.uk'
  s.homepage    =
    'https://github.com/krisquigley/ebook_generator'

  s.add_runtime_dependency 'ruby', '>= 2.0.0'
  s.add_runtime_dependency 'rails', '>= 4.0.0'
  s.add_runtime_dependency 'friendly_id', '>= 5.0.3'
  s.add_runtime_dependency 'pg',  '>= 0.17.1'
  s.add_runtime_dependency 'redcarpet',  '>= 3.0.0'
  s.add_runtime_dependency 'rubyzip',  '>= 1.0.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.license       = 'MIT'
end
