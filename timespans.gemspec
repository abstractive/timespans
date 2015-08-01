# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name         = "timespans"
  gem.version      = "0.0.9"
  gem.platform     = Gem::Platform::RUBY
  gem.summary      = "Time delineation and organization utilities."
  gem.description  = "Time delineation and organization utilities."
  gem.licenses     = ["MIT"]

  gem.authors      = ["digitalextremist //"]
  gem.email        = ["code@extremist.digital"]
  gem.homepage     = "https://github.com/abstractive/timespans"

  gem.required_ruby_version     = ">= 1.9.2"
  gem.required_rubygems_version = ">= 1.3.6"

  gem.files        = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|examples|spec|features)/}) }
  gem.require_path = "lib"
  gem.add_runtime_dependency "abstractive"
  gem.add_runtime_dependency "hitimes", ">= 1.2.2"
end
