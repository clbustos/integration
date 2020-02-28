# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require "integration" 

Gem::Specification.new do |s|
  s.name = "integration"
  s.version = Integration::VERSION
  s.authors = ["Claudio Bustos","Ben Gimpert"]
  s.description = "Numerical integration for Ruby, with a simple interface"
  s.email = ["clbustos@gmail.com", "No Email"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features,benchmark}/*`.split("\n")  
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.summary = "A suite for integration in Ruby"
  s.add_runtime_dependency 'text-table', '~>1.2'
  s.add_runtime_dependency 'rb-gsl', '~>1.2'
  s.add_development_dependency 'rake', '~>13'
  s.add_development_dependency 'bundler', '~>1.3'
  s.add_development_dependency 'rspec', '~>2.0'
end
