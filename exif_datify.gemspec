# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exif_datify/version'

Gem::Specification.new do |spec|
  spec.name          = "exif_datify"
  spec.version       = ExifDatify::VERSION
  spec.authors       = ["Harold Waterkeyn"]
  spec.email         = ["hwaterke@users.noreply.github.com"]

  spec.summary       = %q{Prepend files with date and time from exif information}
  spec.description   = %q{Name files based on exif information}
  spec.homepage      = "https://github.com/hwaterke/exif_datify"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
