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


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.license       = 'MIT'
end
