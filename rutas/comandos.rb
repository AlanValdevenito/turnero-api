get '/version' do
  logger.info('GET /version')
  json({ version: Version.current })
end

post '/reset' do
  halt 403 unless settings.environment == :test

  RepositorioTurnos.new.delete_all
  RepositorioMedicos.new.delete_all
  RepositorioUsuarios.new.delete_all
  RepositorioEspecialidades.new.delete_all

  status 200
  json({ message: 'Datos reiniciados' })
end
