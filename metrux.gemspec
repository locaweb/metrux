# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metrux/version'

Gem::Specification.new do |spec|
  spec.name          = "metrux"
  spec.version       = Metrux::VERSION
  spec.authors       = ['Locaweb']
  spec.email         = ['desenvolvedores@locaweb.com.br']

  spec.summary       = 'An instrumentation library which persists the metrics on InfluxDB.'
  spec.description   = 'An instrumentation library which persists the metrics on InfluxDB.'
  spec.homepage      = 'http://developer.locaweb.com.br'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"

  spec.add_dependency 'activesupport'
  spec.add_dependency 'influxdb', '~> 0.3.5'
end
