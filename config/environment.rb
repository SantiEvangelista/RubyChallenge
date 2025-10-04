# config/environment.rb
require 'active_record'
require 'logger'
require 'fileutils'

# Configure a logger for ActiveRecord
ActiveRecord::Base.logger = Logger.new(STDERR)

# Database configuration (direct SQLite connection)
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/development.sqlite3"
)

# Ensure the database directory exists (this might be redundant if rake db:create handles it)
FileUtils.mkdir_p(File.dirname(ActiveRecord::Base.connection_db_config.database))
