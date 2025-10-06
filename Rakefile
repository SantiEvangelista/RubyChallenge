# Rakefile
require 'rake'
require_relative './config/environment'

# Ensure ActiveRecord is loaded and connected for Rake tasks

namespace :db do
  desc "Create the database"
  task :create do
    # The database file is created when ActiveRecord connects. We only need to ensure the directory exists.
    puts "Ensuring database directory exists..."
    FileUtils.mkdir_p(File.dirname(ActiveRecord::Base.connection_db_config.database))
    puts "Database created/ensured."
  end

  desc "Migrate the database"
  task :migrate => :create do # Ensure db exists before migrating
    ActiveRecord::Migration.verbose = true
    migrations_paths = [File.join(File.dirname(__FILE__), 'db', 'migrate')]
    ActiveRecord::MigrationContext.new(migrations_paths).migrate
    puts "Migrations complete."
  end

  desc "Drop the database"
  task :drop do
    database_path = ActiveRecord::Base.connection_db_config.database
    if File.exist?(database_path)
      File.delete(database_path)
      puts "Database '#{database_path}' dropped."
    else
      puts "Database '#{database_path}' does not exist."
    end
  end

  desc "Rollback the database by number of steps (default: 1)"
  task :rollback, [:steps] => :create do |t, args|
    steps = (args[:steps] || 1).to_i
    migrations_paths = [File.join(File.dirname(__FILE__), 'db', 'migrate')]
    ActiveRecord::MigrationContext.new(migrations_paths).rollback(steps)
    puts "Rollback complete."
  end

  desc "Seed the database with data"
  task :seed => :create do # Ensure db exists before seeding
    require_relative './db/seeds.rb' if File.exist?('./db/seeds.rb')
    puts "Seed data loaded."
  end
end
