lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'salto/version'

Gem::Specification.new do |spec|
  spec.name          = 'salto'
  spec.version       = Salto::VERSION
  spec.authors       = ['Reinier de Lange']
  spec.email         = ['rjdelange@icloud.com']

  spec.summary       = 'Salto PMS client based on the Industry Standard'
  spec.description   = '.class.base_class.model_name'
  spec.homepage      = 'https://github.com/bookingexperts/salto'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'i18n'
  spec.add_dependency 'tcp-client', '~> 0.0.11'

  spec.add_development_dependency 'bundler', '~> 2.5.13'
  spec.add_development_dependency 'm'
  spec.add_development_dependency 'minitest', '~> 5.24.1'
  spec.add_development_dependency 'rake', '~> 13.2.1'
  spec.add_development_dependency 'rubocop', '~> 1.65.0'
end
