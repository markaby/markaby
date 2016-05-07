# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'markaby/version'

Gem::Specification.new do |spec|
  spec.name          = "markaby"
  spec.version       = Markaby::VERSION
  spec.authors       = ["Scott Taylor", "judofyr", "_why"]
  spec.email         = ["scott@railsnewbie.com"]
  spec.description   = "_why's markaby templating language"
  spec.summary       = "A pure ruby based, html markup language"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "builder"
  spec.add_dependency "activesupport"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
