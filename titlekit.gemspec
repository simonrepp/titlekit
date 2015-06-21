require File.expand_path('../lib/titlekit/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name = 'titlekit'
  spec.summary = 'Featureful Ruby library for SRT / ASS / SSA subtitles'
  spec.description = 'Featureful Ruby library for SRT / ASS / SSA subtitles'

  spec.homepage = 'https://github.com/simonrepp/titlekit'

  spec.author = 'Simon Repp'
  spec.email = 'simon@fdpl.foundation'

  spec.license = 'MIT'

  spec.add_runtime_dependency('rchardet19')
  spec.add_runtime_dependency('treetop')

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')

  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.0.0'
  spec.files = `git ls-files`.split($\)
  spec.executables = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.version = Titlekit::VERSION
end
