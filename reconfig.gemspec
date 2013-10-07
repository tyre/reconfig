# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reconfig/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'redis', '= 3.0.5'
  spec.authors     = ['Chris Maddox']
  spec.date        = '2013-10-02'
  spec.description = 'Redis configuration management.'
  spec.email       = 'chris@zenpayroll.com'
  spec.files       = %w(LICENSE.md README.md reconfig.gemspec)
  spec.files      += Dir.glob('lib/**/*.rb')
  spec.files      += Dir.glob('spec/**/*')
  spec.homepage    = 'http://rubygems.org/gems/reconfig'
  spec.licenses    = ['MIT']
  spec.name        = 'reconfig'
  spec.summary     = 'Redis configuration management'
  spec.test_files += Dir.glob('spec/**/*')
  spec.version     = Reconfig::Version.to_s
end