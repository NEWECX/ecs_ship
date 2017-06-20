# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ecs_ship/version'

Gem::Specification.new do |spec|
  spec.name          = "ecs_ship"
  spec.version       = EcsShip::VERSION
  spec.authors       = ["Seth Ringling"]
  spec.email         = ["sethr@ritani.com"]

  spec.summary       = %q{Provides a shipping script for AWS ECS dockerized applications}
  spec.description   = %q{EZ-Deployment of a dockerized app in AWS!}
  spec.homepage      = "https://github.com/NEWECX/ecs_ship"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
