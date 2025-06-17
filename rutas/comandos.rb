get '/version' do
  logger.info('GET /version')
  turnero.usuarios
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

post '/hora_mock' do
  # halt 403 unless settings.environment == :test

  body = JSON.parse(request.body.read)
  hora_str = body['hora'] # ejemplo: "22:00" o "1:00"
  raise ArgumentError, 'Debe enviar el campo "hora"' unless hora_str

  hora, min = hora_str.split(':').map(&:to_i)
  turnero.setear_hora_mock(hora, min)

  status 200
  json({ message: "Hora mock seteada a #{hora_str}" })
rescue ArgumentError => e
  status 400
  json({ error: e.message })
rescue StandardError
  status 400
  json({ error: 'Error al setear la hora mock' })
end

# Eliminar la hora mock (DELETE porque elimina un recurso)
delete '/hora_mock' do
  # halt 403 unless settings.environment == :test

  turnero.cancelar_hora_mock

  status 200
  json({ message: 'Hora mock cancelada' })
end
