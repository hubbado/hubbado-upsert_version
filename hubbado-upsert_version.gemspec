Gem::Specification.new do |spec|
  spec.name          = "hubbado-upsert_version"
  spec.version       = '3.0.0'
  spec.authors       = ["Hubbado"]
  spec.email         = ["devs@hubbado.com"]
  spec.summary       = %q{An ActiveRecord based library for upserting with a per row version}
  spec.homepage      = "https://www.github.com/hubbado/hubbado-upsert_version"

  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/hubbado"
  spec.metadata["github_repo"] = spec.homepage
  spec.metadata["homepage_uri"] = spec.homepage

  spec.require_paths = ["lib"]
  spec.files = Dir.glob("{lib}/**/*")
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 3.4"

  spec.add_runtime_dependency 'activerecord'
  spec.add_runtime_dependency 'evt-configure'
  spec.add_runtime_dependency 'evt-mimic'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "evt-dependency"
  spec.add_development_dependency "lockbox"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "database_cleaner-active_record"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'standalone_migrations'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-cobertura'
end
