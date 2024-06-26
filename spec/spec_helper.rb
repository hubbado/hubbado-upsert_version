require "bundler/setup"
require "hubbado/upsert_version"
require 'lockbox'
require 'support/db/establish_connection'
require 'hubbado/upsert_version/controls'
require 'hubbado/upsert_version/controls/models'
require 'debug'
require 'database_cleaner/active_record'

LOCKBOX_TEST_KEY = '0000000000000000000000000000000000000000000000000000000000000000'.freeze

if ENV['CI'] == 'true'
  require 'simplecov'
  require 'simplecov-cobertura'

  SimpleCov.start
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

RSpec.configure do |config|
  config.before(:suite) do
    Lockbox.master_key = LOCKBOX_TEST_KEY
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
