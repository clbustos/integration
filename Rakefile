# -*- ruby -*-
$:.unshift(File.expand_path(File.dirname(__FILE__)+"/lib/"))
require 'rubygems'
require 'integration'
require 'bundler'

gemspec = eval(IO.read("integration.gemspec"))


begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "rubygems/package_task"
Gem::PackageTask.new(gemspec).define

desc "install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/integration-#{Integration::VERSION}.gem}
end

require 'rspec/core/rake_task'
require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end


desc "Open an irb session preloaded with integration"
task :console do
  sh "irb -rubygems -I lib -r integration.rb"
end

task :default => :spec
# vim: syntax=ruby
