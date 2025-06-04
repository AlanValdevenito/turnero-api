require 'sinatra'
require 'sinatra/json'
require 'sequel'
require 'sinatra/custom_logger'
require_relative './config/configuration'
require_relative './lib/version'
Dir[File.join(__dir__, 'dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'persistencia', '*.rb')].each { |file| require file }

configure do
  customer_logger = Configuration.logger
  DB = Configuration.db # rubocop:disable  Lint/ConstantDefinitionInBlock
  DB.loggers << customer_logger
  set :logger, customer_logger
  set :default_content_type, :json
  set :environment, ENV['APP_MODE'].to_sym
  set :turnero, Turnero.new(RepositorioUsuarios.new, RepositorioMedicos.new, RepositorioEspecialidades.new, RepositorioTurnos.new)
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

post '/reset' do
  halt 403 unless settings.environment == :test

  RepositorioMedicos.new.delete_all
  RepositorioUsuarios.new.delete_all
  RepositorioEspecialidades.new.delete_all

  status 200
  json({ message: 'Datos reiniciados' })
end

get '/version' do
  logger.info('Handling /version')
  json({ version: Version.current })
end

post '/medicos' do
  logger.debug("POST /medicos: #{@params}")
  medico = turnero.crear_medico(@params[:nombre], @params[:apellido], @params[:matricula], @params[:especialidad])
  status 200
  { message: 'El médico fue dado de alta correctamente.', id: medico.id }.to_json
end

get '/medicos' do
  medicos = turnero.medicos
  respuesta = []
  medicos.map { |m| respuesta << { nombre: m.nombre, apellido: m.apellido, matricula: m.matricula, especialidad: m.especialidad.nombre } }
  status 200
  json(respuesta)
end

post '/especialidades' do
  logger.debug("POST /especialidades: #{@params}")
  especialidad = turnero.crear_especialidad(@params[:nombre], @params[:duracion_de_turnos])
  status 200
  { message: 'La especialidad fue dada de alta correctamente.', id: especialidad.id }.to_json
end

get '/especialidades' do
  logger.debug('GET /especialidades')
  especialidades = turnero.especialidades
  respuesta = []
  especialidades.map { |e| respuesta << { nombre: e.nombre, duracion_de_turnos: e.duracion_de_turnos } }
  status 200
  json(respuesta)
end

get '/turnos/medicos-disponibles' do
  logger.debug('GET /turnos/medicos-disponibles')
  medicos = turnero.medicos_disponibles
  respuesta = []
  medicos.each do |medico|
    respuesta << { id: medico.id, nombre: medico.nombre, apellido: medico.apellido, matricula: medico.matricula, especialidad: medico.especialidad.nombre }
  end
  status 200
  json(respuesta)
end

get '/turnos/:matricula/disponibilidad' do
  logger.debug("GET /turnos/#{params[:matricula]}/disponibilidad")
  matricula = params[:matricula]
  begin
    disponibilidad = turnero.disponibilidad_de_medico(matricula)
    respuesta = disponibilidad.map do |turno|
      { fecha: turno.fecha, hora: turno.hora, duracion: turno.duracion }
    end
    status 200
    json(respuesta)
  rescue MedicoNoEncontradoException
    status 404
    json({ error: 'Médico no encontrado' })
  end
end

get '/usuarios' do
  usuarios = turnero.usuarios
  respuesta = []
  usuarios.map { |u| respuesta << { email: u.email, id: u.id } }
  status 200
  json(respuesta)
end

get '/usuarios/:email' do
  email = params[:email]
  usuario = turnero.buscar_usuario_por_email(email)
  if usuario
    status 200
    json({ id: usuario.id, email: usuario.email })
  else
    status 404
    json({ error: 'Usuario no encontrado' })
  end
end

post '/usuarios' do
  logger.debug("POST /usuarios: #{@params}")
  begin
    usuario = turnero.crear_usuario(@params[:email], @params[:telegram_id])
    status 201
    json({ id: usuario.id, email: usuario.email, telegram_id: usuario.telegram_id, message: 'El paciente se registró existosamente' })
  rescue EmailEnUsoException
    status 400
    json({ error: 'El email ingresado ya está en uso' })
  rescue TelegramIdEnUsoException
    status 400
    json({ error: 'El paciente ya se encuentra registrado' })
  rescue EmailObligatorioException
    status 400
    json({ error: 'El email es obligatorio' })
  end
end
