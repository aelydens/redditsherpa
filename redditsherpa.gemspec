# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redditsherpa/version'

Gem::Specification.new do |spec|
  spec.name          = "redditsherpa"
  spec.version       = Redditsherpa::VERSION
  spec.authors       = ["Annie Lydens"]
  spec.email         = ["aelydens@gmail.com"]
  spec.summary       = %q{Read reddit from the command line.}
  spec.description   = %q{Read reddit from the command line.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'httparty'
  spec.add_dependency 'pry'
  spec.add_dependency 'faraday'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
