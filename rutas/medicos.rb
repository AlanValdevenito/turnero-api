post '/medicos' do
  logger.debug("POST /medicos: #{@params}")
  medico = turnero.crear_medico(@params[:nombre], @params[:apellido], @params[:matricula], @params[:especialidad])
  status 200
  { message: 'El médico fue dado de alta correctamente.', id: medico.id }.to_json
end

get '/medicos' do
  logger.debug('GET /medicos')
  medicos = turnero.medicos
  respuesta = []
  medicos.map { |m| respuesta << { nombre: m.nombre, apellido: m.apellido, matricula: m.matricula, especialidad: m.especialidad.nombre } }
  status 200
  json(respuesta)
end

delete '/medicos/:matricula' do
  logger.debug("DELETE /medicos/:matricula : #{@params}")
  turnero.eliminar_medico_por_matricula(@params[:matricula])
  status 200
  { message: 'El médico eliminado', id: medico.id }.to_json
end
