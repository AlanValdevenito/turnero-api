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

# PARA TESTEAR LA US-11 (USO EXCLUSIVO)
post '/test/hora_mock' do
  # halt 403 unless settings.environment == :test
  hora = params[:hora]
  raise ArgumentError, 'Debe enviar el campo "hora"' unless hora

  turnero.setear_hora_mock(hora)

  status 200
  json({ message: "Hora mock seteada a #{hora}" })
rescue ArgumentError => e
  status 400
  json({ error: e.message })
rescue StandardError => e
  status 400
  json({ error: 'Error al setear la hora mock', details: e.message })
end

# Eliminar la hora mock (DELETE porque elimina un recurso)
delete '/test/hora_mock' do
  # halt 403 unless settings.environment == :test

  turnero.cancelar_hora_mock

  status 200
  json({ message: 'Hora mock cancelada' })
end
