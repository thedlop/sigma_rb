Gem::Specification.new do |s|
  s.name        = 'sigma_rb'
  s.version     = '0.2.0'
  s.summary     = "Ruby bindings for Ergo types, abstractions, and interfaces provided by Sigma-Rust."
  s.description = "Ruby bindings for the Ergo-Lib crate of Sigma-Rust. Specifically for chain types and abstractions, json serialization, box selection for tx inputs, tx creation, and signing."
  s.authors     = ["Dark Lord of Programming"]
  s.email       = 'thedlop@sent.com'
  s.homepage    = 'https://github.com/thedlop/sigma_rb'
  s.license       = 'MIT'
  s.files = Dir.glob("{lib}/**/*")
  s.files += %w(sigma.gemspec README.md LICENSE ext/Rakefile ext/csigma.c)
  s.add_dependency 'ffi-compiler', '1.0.1'
  s.add_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'ffi', '1.15.5'
  s.add_development_dependency 'test-unit', '~> 3.5'
  s.add_development_dependency 'yard', '~> 0.9.20'
  s.extensions << "ext/Rakefile"
  s.test_files = Dir["tests/**/*.rb"]
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 3.0.1'
end
