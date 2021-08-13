require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'standalone_migrations'

RSpec::Core::RakeTask.new(:spec)
StandaloneMigrations::Tasks.load_tasks

task default: :spec
