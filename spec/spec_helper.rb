require "bundler/setup"
require "hubbado/upsert_version"
require 'attr_encrypted'
require 'support/models'
require 'byebug'
require 'database_cleaner/active_record'

if ENV['CI'] == 'true'
  require 'simplecov'
  SimpleCov.start

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

RSpec.configure do |config|
  config.before(:suite) do
    ENV['RACK_ENV'] = 'test'
    db_yml = YAML.load_file(ERB.new(File.join('db', 'config.yml')).result)

    ActiveRecord::Base.configurations = db_yml
    ActiveRecord::Base.establish_connection

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
