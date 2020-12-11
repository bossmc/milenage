# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'milenage/version'

Gem::Specification.new do |spec|
  spec.name          = "milenage"
  spec.version       = Milenage::VERSION
  spec.authors       = ["Andy Caldwell"]
  spec.email         = ["andy.m.caldwell@googlemail.com"]
  spec.description   = %q{Ruby implementation of the Milenage algorithm}
  spec.summary       = %q{Ruby implementation of the Milenage algorithm from 
                          TS 35.206 using OpenSSL to calculate the Rinjdael
                          kernel functions}
  spec.homepage      = "https://github.com/bossmc/milenage"
  spec.license       = "LGPLv3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "rspec"
end
