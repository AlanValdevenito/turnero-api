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
post '/test/fecha_mock' do
  # halt 403 unless settings.environment == :test
  fecha = params[:fecha]
  hora = params[:hora]
  raise ArgumentError, 'Debe enviar el campo "hora"' unless hora
  raise ArgumentError, 'Debe enviar el campo "fecha"' unless fecha

  turnero.setear_fecha_mock(fecha, hora)

  status 200
  json({ message: "Fecha mock seteada a #{fecha} #{hora}" })
rescue ArgumentError => e
  status 400
  json({ error: e.message })
rescue StandardError => e
  status 400
  json({ error: 'Error al setear la hora mock', details: e.message })
end

# Eliminar la hora mock (DELETE porque elimina un recurso)
delete '/test/fecha_mock' do
  # halt 403 unless settings.environment == :test

  turnero.cancelar_fecha_mock

  status 200
  json({ message: 'Fecha mock cancelada' })
end
