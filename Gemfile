source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in activerecord-upsert_version.gemspec
gemspec

group :development do
  source "https://rubygems.pkg.github.com/hubbado" do
    gem 'hubbado-style'
  end
  gem 'pg', '~> 0.21.0'
end
