require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'standalone_migrations'

class File
  class << self
    alias_method :exists?, :exist?
  end
end

RSpec::Core::RakeTask.new(:spec)
ENV["SCHEMA"] = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "schema.rb")
StandaloneMigrations::Tasks.load_tasks

task default: :spec
