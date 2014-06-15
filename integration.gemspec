# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'integration/version'

Gem::Specification.new do |spec|
  spec.name          = 'integration'
  spec.version       = IntegrationLib::VERSION
  spec.authors       = ['Ben Gimpert', 'Claudio Bustos', 'Oleg Bovykin']
  spec.email         = ['clbustos_at_gmail.com', 'oleg.bovykin@gmail.com']
  spec.summary       = %q{Integration methods, based on original work by Beng}
  spec.description   = %q{Numerical integration for Ruby, with a simple interface}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.add_runtime_dependency 'rb-gsl'
  spec.add_runtime_dependency 'activesupport'
end
