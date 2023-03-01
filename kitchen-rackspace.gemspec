lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/rackspace_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-rackspace'
  spec.version       = Kitchen::Driver::RACKSPACE_VERSION
  spec.authors       = ['Jonathan Hartman']
  spec.email         = %w[j@p4nt5.com]
  spec.description   = 'A Test Kitchen Rackspace driver'
  spec.summary       = 'A Test Kitchen Rackspace driver built on Fog'
  spec.homepage      = 'https://github.com/test-kitchen/kitchen-rackspace'
  spec.license       = 'Apache'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib]

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'fog-rackspace', '~> 0.1'
  # there is a bug in 2.3.0 which is causing the fog/rackspace gem to fail.
  # We can remove this once https://github.com/fog/fog-core/issues/279 is fixed.
  spec.add_dependency 'fog-core', '~> 2.2.0'
  spec.add_dependency 'test-kitchen', '>= 1.1', '< 4.0'

  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.28.2'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'simplecov-console', '~> 0.2'
end
