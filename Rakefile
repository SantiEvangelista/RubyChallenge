# Rakefile
require 'rake'
require_relative './config/environment'

# Load Rswag rake tasks
begin
  require 'rswag/specs/rake_task'
  RSwag::Specs::RakeTask.new('rswag:specs:swaggerize')
rescue LoadError
  # Rswag not available
end

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

namespace :api do
  desc "Generate API documentation from Rswag specs"
  task :docs do
    puts "Generating API documentation with Rswag..."
    Rake::Task['rswag:specs:swaggerize'].invoke
    
    # Copy generated swagger to public folder for easy access
    source = File.join('swagger', 'v1', 'swagger.yaml')
    destination = File.join('public', 'openapi.yaml')
    
    if File.exist?(source)
      FileUtils.cp(source, destination)
      puts "Documentation generated successfully!"
      puts "✓ Swagger file: #{source}"
      puts "✓ Public file: #{destination}"
    else
      puts "Warning: Swagger file not found at #{source}"
    end
  end
  
  desc "Generate and view API documentation"
  task :docs_view => :docs do
    puts "\nYou can now view the documentation at:"
    puts "http://localhost:8080/openapi.yaml"
  end
end
