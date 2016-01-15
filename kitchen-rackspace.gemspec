# Encoding: UTF-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/rackspace_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-rackspace'
  spec.version       = Kitchen::Driver::RACKSPACE_VERSION
  spec.authors       = ['Jonathan Hartman']
  spec.email         = %w(j@p4nt5.com)
  spec.description   = 'A Test Kitchen Rackspace driver'
  spec.summary       = 'A Test Kitchen Rackspace driver built on Fog'
  spec.homepage      = 'https://github.com/test-kitchen/kitchen-rackspace'
  spec.license       = 'Apache'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'test-kitchen', '~> 1.1'
  spec.add_dependency 'fog', '~> 1.18'

  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.29'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'simplecov-console', '~> 0.2'
  spec.add_development_dependency 'coveralls', '~> 0.8'
end
