# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mail_address/version'

Gem::Specification.new do |spec|
  spec.name          = "mail_address"
  spec.version       = MailAddress::VERSION
  spec.authors       = ["Kizashi Nagata"]
  spec.email         = ["kizashi1122@gmail.com"]
  spec.summary       = %q{Simple Mail Address Parser}
  spec.description   = %q{A practical mail address parser implemented based on Perl Module Mail::Address.}
  spec.homepage      = "https://github.com/kizashi1122/mail_address"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.1', '>= 3.1.0'
  spec.add_development_dependency "coveralls"
end
