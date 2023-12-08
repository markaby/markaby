require_relative "lib/markaby/version"

Gem::Specification.new do |spec|
  spec.name = "markaby"
  spec.version = Markaby::VERSION
  spec.authors = ["Scott Taylor", "judofyr", "_why"]
  spec.email = ["scott@railsnewbie.com"]
  spec.description = "_why's markaby templating language"
  spec.summary = "A pure ruby based, html markup language"
  spec.homepage = ""
  spec.license = "MIT"

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "builder"
  spec.add_development_dependency "bundler", ">= 2.2.10"
  spec.add_development_dependency "rake"
  spec.required_ruby_version = '>= 2.7.0'
end
