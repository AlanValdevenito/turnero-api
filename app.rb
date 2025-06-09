require 'sinatra'
require 'sinatra/json'
require 'sequel'
require 'sinatra/custom_logger'
require 'dotenv/load'
require_relative './config/configuration'
require_relative './lib/version'
Dir[File.join(__dir__, 'dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'dominio/adapters', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'persistencia', '*.rb')].each { |file| require file }

configure do
  customer_logger = Configuration.logger
  DB = Configuration.db # rubocop:disable  Lint/ConstantDefinitionInBlock
  DB.loggers << customer_logger
  set :logger, customer_logger
  set :default_content_type, :json
  set :environment, ENV['APP_MODE'].to_sym
  set :turnero, Turnero.new(RepositorioUsuarios.new, RepositorioMedicos.new, RepositorioEspecialidades.new, RepositorioTurnos.new, ProveedorDia.new, ProveedorFeriados.new)
  customer_logger.info('Iniciando turnero...')
end

before do
  if !request.body.nil? && request.body.size.positive?
    request.body.rewind
    @params = JSON.parse(request.body.read, symbolize_names: true)
  end
end

def turnero
  settings.turnero
end

Dir[File.join(__dir__, 'rutas', '*.rb')].each { |file| require_relative file }