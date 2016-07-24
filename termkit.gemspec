# coding: UTF-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'termkit/version'

Gem::Specification.new do |spec|
	spec.name          = 'termkit'
	spec.version       = TheFox::TermKit::VERSION
	spec.date          = TheFox::TermKit::DATE
	spec.author        = 'Christian Mayer'
	spec.email         = 'christian@fox21.at'
	
	spec.summary       = %q{Terminal Model-View-Controller Framework}
	spec.description   = %q{A Model-View-Controller Framework for Terminal applications.}
	spec.homepage      = TheFox::TermKit::HOMEPAGE
	spec.license       = 'GPL-3.0'
	
	spec.files         = `git ls-files -z`.split("\x0").reject{ |f| f.match(%r{^(test|spec|features)/}) }
	spec.require_paths = ['lib']
	spec.required_ruby_version = '>=2.1.0'
	
	spec.add_development_dependency 'minitest', '~>5.8'
end
