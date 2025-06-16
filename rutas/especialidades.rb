post '/especialidades' do
  logger.debug("POST /especialidades: #{@params}")
  especialidad = turnero.crear_especialidad(@params[:nombre], @params[:duracion_de_turnos], @params[:limite_turnos_por_usuario])
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
