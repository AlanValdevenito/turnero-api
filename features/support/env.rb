# rubocop:disable all
ENV['APP_MODE'] = 'test'
require 'rack/test'
require 'rspec/expectations'
require 'rspec/mocks'
require_relative '../../app.rb'
require 'faraday'


DB = Configuration.db
Sequel.extension :migration
logger = Configuration.logger
db = Configuration.db
db.loggers << logger
Sequel::Migrator.run(db, 'db/migrations')
World(RSpec::Mocks::ExampleMethods)

include Rack::Test::Methods
def app
  Sinatra::Application
end

Before do
  RSpec::Mocks.setup
end

After do |_scenario|
  Faraday.post('/reset')
  RSpec::Mocks.teardown
end
