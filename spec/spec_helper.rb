require "bundler/setup"
require "hubbado/upsert_version"
require 'support/models'
require 'pg_tester'
require 'byebug'

if ENV['CI'] == 'true'
  require 'simplecov'
  SimpleCov.start

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

RSpec.configure do |config|
  config.before(:suite) do
    psql = PgTester.new(database: 'upsert_version')
    psql.setup

    ActiveRecord::Base.establish_connection(
      adapter: "postgresql",
      host: psql.host,
      database: psql.database,
      user: psql.user,
      port: psql.port
    )

    load File.dirname(__FILE__) + '/schema.rb'
  end

  config.after(:suite) do
    PgTester.new(database: 'upsert_version').teardown
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
