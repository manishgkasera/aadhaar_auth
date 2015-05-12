# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aadhaar_auth/version'

Gem::Specification.new do |spec|
  spec.name          = "aadhaar_auth"
  spec.version       = AadhaarAuth::VERSION
  spec.authors       = ["Manish Kasera"]
  spec.email         = ["manishgkasera@gmail.com"]
  spec.summary       = %q{Aadhaar auth api: ruby port}
  spec.description   = %q{Aadhaar auth api v1.6: ruby port}
  spec.homepage = 'https://github.com/manishgkasera/aadhaar_auth'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "xmldsig", "0.2.8"
  spec.add_runtime_dependency "nokogiri", "1.5.2"
  spec.add_runtime_dependency "curb", "0.8.6"
end
