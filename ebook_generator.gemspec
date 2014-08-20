# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ebook_generator/version"

Gem::Specification.new do |spec|
  spec.name        = 'ebook_generator'
  spec.version     = EbookGenerator::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.summary     = "Generates eBooks"
  spec.description = "A simple eBook (ePub and Mobi) generator gem"
  spec.authors     = ["affinity tech"]
  spec.email       = 'info@affinity-tech.com'
  spec.homepage    =
    'http://www.affinity-tech.com'

  spec.add_runtime_dependency 'rails', '>= 4.0.0'
  spec.add_runtime_dependency 'friendly_id', '>= 5.0.3'
  spec.add_runtime_dependency 'pg',  '>= 0.17.1'
  spec.add_runtime_dependency 'redcarpet',  '>= 3.0.0'
  spec.add_runtime_dependency 'rubyzip',  '>= 1.0.0'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'fakefs'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.license       = 'MIT'
end
