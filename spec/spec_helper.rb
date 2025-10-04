# spec/spec_helper.rb
require "bundler/setup"
require "rack/test"
require "rspec"
require "json"
require_relative "../app"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching! 

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
