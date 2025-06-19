post '/especialidades' do
  logger.debug("POST /especialidades: #{@params}")
  especialidad = turnero.crear_especialidad(@params[:nombre], @params[:duracion_de_turnos], @params[:limite_turnos_por_usuario])
  status 200
  { message: 'La especialidad fue dada de alta correctamente.', id: especialidad.id }.to_json
rescue EspecialidadDuplicadaException
  status 409
  { error: 'La especialidad ya existe' }.to_json
end

get '/especialidades' do
  logger.debug('GET /especialidades')
  especialidades = turnero.especialidades
  respuesta = []
  especialidades.map { |e| respuesta << { nombre: e.nombre, duracion_de_turnos: e.duracion_de_turnos, limite_turnos_por_usuario: e.limite_turnos_por_usuario } }
  status 200
  json(respuesta)
end

put '/especialidades/:nombre' do
  logger.debug("PUT /especialidades/:nombre: #{@params}")
  nombre = params['nombre']
  nuevo_nombre = @params[:nombre]
  nuevo_limite = @params[:limite_turnos_por_usuario]
  begin
    especialidad = turnero.modificar_especialidad(nombre, nuevo_nombre, nuevo_limite)
    status 200
    json({ id: especialidad.id, nombre: especialidad.nombre, duracion_de_turnos: especialidad.duracion_de_turnos, limite_turnos_por_usuario: especialidad.limite_turnos_por_usuario })
  rescue EspecialidadNoEncontradaException
    status 404
    json({ error: 'Especialidad no encontrada' })
  rescue LimiteDeTurnosNoPositivoException
    status 400
    json({ error: 'El limite de turnos por usuario debe ser un entero positivo' })
  rescue LimiteDeTurnosNoEnteroException
    status 400
    json({ error: 'El limite de turnos por usuario debe ser un numero entero' })
  end
end

delete '/especialidades/:nombre' do
  logger.debug("DELETE /especialidades/:nombre : #{@params}")
  begin
    turnero.eliminar_especialidad_por_nombre(@params[:nombre])
    status 200
    { message: 'Especialidad eliminada con sus medicos y turnos correspondientes' }.to_json
  rescue EspecialidadNoEncontradaException
    status 404
    json({ error: 'Especialidad no encontrada' })
  end
end
