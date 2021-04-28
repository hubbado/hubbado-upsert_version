
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hubbado/upsert_version/version"

Gem::Specification.new do |spec|
  spec.name          = "hubbado-upsert_version"
  spec.version       = Hubbado::UpsertVersion::VERSION
  spec.authors       = ["Stanislaw Klajn", "Sam Stickland"]
  spec.email         = ["stan@hubbado.com", "sam@hubbado.com"]

  spec.summary       = %q{An ActiveRecord based library for upserting with a per row version}
  spec.homepage      = "https://www.github.com/hubbado/hubbado-upsert_version"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/hubbado"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activerecord'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "codecov"
  spec.add_development_dependency "ffaker"
  spec.add_development_dependency "pg_tester"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
