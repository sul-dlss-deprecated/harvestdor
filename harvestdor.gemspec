# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'harvestdor/version'

Gem::Specification.new do |gem|
  gem.name          = "harvestdor"
  gem.version       = Harvestdor::VERSION
  gem.authors       = ["Naomi Dushay"]
  gem.email         = ["ndushay@stanford.edu"]
  gem.description   = %q{Harvest DOR object metadata from a Stanford public purl page}
  gem.summary       = %q{Harvest DOR object metadata}
  gem.homepage      = "https://github.com/sul-dlss/harvestdor"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'confstruct'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'faraday'

  # Development dependencies
  gem.add_development_dependency "rake"
  # docs
  gem.add_development_dependency "rdoc"
  gem.add_development_dependency "yard"
  # tests
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'coveralls'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop-rspec'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'webmock'
end
