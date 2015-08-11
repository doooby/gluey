lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gluey/common/version'

Gem::Specification.new do |spec|
  spec.name          = 'gluey'
  spec.version       = Gluey::VERSION
  spec.authors       = ['doooby']
  spec.email         = ['zelazk.o@email.cz']
  spec.summary       = 'Rails\' asset pipelane replacement'
  spec.description   = %q{Concatenating and processing asset files with possibly complicated dependencies.}
  # spec.homepage      = ""
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
