# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)


Gem::Specification.new do |s|
  s.name = "integration"
  s.version = "0.1.1"
  s.authors = ["Claudio Bustos","Ben Gimpert"]
  s.description = "Numerical integration for Ruby, with a simple interface"
  s.email = ["clbustos@gmail.com", "No Email"]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.summary = "A suite for integration in Ruby"
  s.add_development_dependency 'rake', '~>0.9'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec', '>=2.0'
  s.add_development_dependency 'rubyforge'
end
