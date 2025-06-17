# rubocop:disable all
ENV['APP_MODE'] = 'test'
require 'rack/test'
require 'rspec/expectations'
require 'rspec/mocks'
require_relative '../../app.rb'
require 'faraday'
require 'webmock/cucumber'


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

def api_get(path, headers = {})
  Faraday.get(path, nil, { 'HTTP_X_API_KEY' => ENV['API_KEY'] }.merge(headers))
end

def api_post(path, body, headers = {})
  Faraday.post(path, body, { 'Content-Type' => 'application/json', 'HTTP_X_API_KEY' => ENV['API_KEY'] }.merge(headers))
end

def api_put(path, body, headers = {})
  Faraday.put(path, body, { 'Content-Type' => 'application/json', 'HTTP_X_API_KEY' => ENV['API_KEY'] }.merge(headers))
end

def api_delete(path, headers = {})
  Faraday.delete(path, nil, { 'HTTP_X_API_KEY' => ENV['API_KEY'] }.merge(headers))
end

Before do
  RSpec::Mocks.setup

  stub_request(:get, %r{https://nolaborables\.com\.ar/api/v2/feriados/\d{4}})
  .to_return(
    status: 200,
    body: '[{ "dia": 16, "mes": 6 }]',
    headers: { 'Content-Type' => 'application/json' }
  )
end

After do |_scenario|
  Faraday.post('/reset')
  RSpec::Mocks.teardown
end
