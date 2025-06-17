Dir[File.join(__dir__, '../dominio/excepciones', '*.rb')].each { |file| require file }

get '/turnos/medicos-disponibles/:especialidad' do
  logger.debug("GET /turnos/medicos-disponibles/:especialidad: #{@params}")
  especialidad = params[:especialidad]
  begin
    medicos = turnero.medicos_disponibles_especialidad(especialidad)
    respuesta = []
    medicos.each do |medico|
      respuesta << { id: medico.id, nombre: medico.nombre, apellido: medico.apellido, matricula: medico.matricula, especialidad: medico.especialidad.nombre }
    end
    status 200
    json(respuesta)
  rescue EspecialidadSinMedicosException
    status 404
    json({ error: 'Especialidad sin medicos dados de alta' })
  end
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
  logger.debug("GET /turnos/:matricula/disponibilidad: #{@params}")
  matricula = params[:matricula]
  begin
    disponibilidad = turnero.disponibilidad_de_medico(matricula)
    if disponibilidad.empty?
      status 400
      return json({ error: 'No hay turnos disponibles para este médico' })
    end
    respuesta = disponibilidad.map do |fecha_hora|
      {
        fecha: fecha_hora.strftime('%Y-%m-%d'),
        hora: fecha_hora.strftime('%H:%M'),
        matricula:
      }
    end
    status 200
    json(respuesta)
  rescue MedicoNoEncontradoException
    status 404
    json({ error: 'Médico no encontrado' })
  end
end

get '/turnos/pacientes/:email' do
  logger.debug("GET /turnos/pacientes/:email: #{params}")
  begin
    email = params[:email]
    respuesta = []
    turnos = turnero.turnos_paciente(email)
    turnos.map do |e|
      respuesta << { fecha: e.fecha_hora.strftime('%Y-%m-%d'), hora: e.fecha_hora.strftime('%H:%M'), estado: e.estado, medico: "#{e.medico.nombre} #{e.medico.apellido}",
                     especialidad: e.medico.especialidad.nombre }
    end
    status 200
    json(respuesta)
  rescue UsuarioNoEncontradoException
    status 404
    json({ error: "Paciente con email #{email} inexistente" })
  end
end

get '/turnos/pacientes/proximos/:email' do
  logger.debug("GET /turnos/pacientes/proximos/:email #{params}")
  email = params[:email]
  respuesta = []
  begin
    turnos = turnero.proximos_turnos_paciente(email)
    turnos.map do |e|
      respuesta << {
        id: e.id,
        'fecha y hora': e.fecha_hora.strftime('%Y-%m-%d %H:%M').to_s,
        especialidad: e.medico.especialidad.nombre,
        medico: "#{e.medico.nombre} #{e.medico.apellido}"
      }
    end
    status 200
    json(respuesta)
  rescue NoHayProximosTurnosException
    status 400
    json({ error: 'El paciente no tiene próximos turnos' })
  end
end

get '/turnos/pacientes/historial/:email' do
  logger.debug("GET /turnos/pacientes/historial/:email #{params}")
  email = params[:email]
  respuesta = []

  begin
    turnos = turnero.historial_turnos_paciente(email)
    turnos.map do |e|
      respuesta << {
        'id': e.id,
        'fecha y hora': e.fecha_hora.strftime('%Y-%m-%d %H:%M').to_s,
        'especialidad': e.medico.especialidad.nombre,
        'medico': "#{e.medico.nombre} #{e.medico.apellido}",
        'estado': e.estado
      }
    end

    status 200
    json(respuesta)
  rescue NoHayHistorialTurnosException
    status 400
    json({ error: 'El paciente no tiene turnos en su historial' })
  end
end

get '/turnos/medicos/:matricula' do
  logger.debug("GET /turnos/medicos/:matricula: #{params}")
  begin
    respuesta = []
    matricula = params[:matricula]
    turnos = turnero.turnos_medico(matricula)
    turnos.map do |e|
      respuesta << { id: e.id, fecha: e.fecha_hora.strftime('%Y-%m-%d'), hora: e.fecha_hora.strftime('%H:%M'), estado: e.estado, paciente_email: e.usuario.email }
    end
    status 200
    json(respuesta)
  rescue MedicoNoEncontradoException
    status 404
    json({ error: "Medico con matricula #{matricula} inexistente" })
  end
end

post '/turnos' do
  logger.debug("POST /turnos: #{@params}")
  begin
    turno = turnero.crear_turno(params[:matricula], params[:fecha], params[:hora], params[:email])
    status 201
    json(turno_a_json(turno))
  rescue StandardError => e
    manejar_error_crear_turno(e)
  end
end

put '/turnos/:id' do
  logger.debug("PUT /turnos/:id: #{@params}")
  id = params['id']
  estado = @params[:estado]
  begin
    turno = turnero.modificar_estado_turno(id, estado)
    status 200
    json({ mensaje: "Turno actualizado: estado #{turno.estado}" })
  rescue StandardError => e
    manejar_error_modificacion_turno(e, estado)
  end
end

put '/turnos/:id/cancelacion' do
  logger.debug("PUT /turnos/:id/cancelacion: #{@params}")
  id = @params['id']
  email = @params[:email]
  confirmacion = @params[:confirmacion]
  begin
    turno = turnero.cancelar_turno(id, email, confirmacion)
    status 200
    json({ mensaje: "Turno actualizado: estado #{turno.estado}" })
  rescue TurnoNoEncontradoException
    status 404
    json({ mensaje: 'Turno no encontrado' })
  rescue TurnoNoPerteneceAUsuarioException
    status 403
    json({ mensaje: 'No puedes cancelar este turno' })
  end
end

helpers do
  def errores_not_found
    {
      UsuarioNoEncontradoException => -> { halt 404, json({ error: 'Usuario no encontrado' }) },
      MedicoNoEncontradoException => -> { halt 404, json({ error: 'Médico no encontrado' }) }
    }
  end

  def errores_bad_request
    {
      FechaNoValidaException => -> { halt 400, json({ error: 'Fecha inválida para agendar un turno' }) },
      TurnoYaExisteException => -> { halt 400, json({ error: 'Ya existe un turno para ese médico y fecha/hora' }) },
      PenalizacionPorReputacionException => -> { halt 400, json({ error: 'Penalización por porcentaje de asistencia abajo del 80%' }) }
    }
  end

  def errores_unprocessable_entity
    {
      LimiteTurnosExcedidoException => -> { halt 422, json({ error: 'El usuario ha alcanzado el límite de turnos para esta especialidad' }) }
    }
  end

  def errores_conflict
    {
      SuperposicionDeTurnosException => -> { halt 409, json({ error: 'Ya existe un turno reservado en esa fecha y horario' }) }
    }
  end
end

helpers do
  def errores_crear_turno
    errores_not_found.merge(errores_bad_request).merge(errores_unprocessable_entity).merge(errores_conflict)
  end

  def manejar_error_crear_turno(error)
    handler = errores_crear_turno[error.class]
    handler ? handler.call : raise(error)
  end
end

helpers do
  def manejar_error_modificacion_turno(error, estado)
    case error
    when ArgumentError
      halt 404, json({ mensaje: 'Id inválido: debe ser un entero' })
    when TurnoYaPasadoException
      halt 400, json({ mensaje: 'No se puede cancelar un turno ya pasado' })
    when TurnoFuturoException
      halt 400, json({ mensaje: "No se puede marcar como #{estado} un turno futuro" })
    when TurnoNoEncontradoException
      halt 404, json({ mensaje: 'Turno no encontrado' })
    when EstadoNoPermitidoException
      halt 409, json({ mensaje: 'No se puede cambiar el estado de un turno que no este pendiente' })
    when EstadoInvalidoException
      halt 400, json({ mensaje: 'Estado inválido para el turno' })
    else
      halt 500, json({ mensaje: 'Error inesperado' })
    end
  end
end

helpers do
  def turno_a_json(turno)
    {
      message: 'El turno se reservó exitosamente',
      id: turno.id,
      fecha: turno.fecha_hora.strftime('%Y-%m-%d'),
      hora: turno.fecha_hora.strftime('%H:%M'),
      medico: {
        nombre: turno.medico.nombre,
        apellido: turno.medico.apellido,
        matricula: turno.medico.matricula,
        especialidad: turno.medico.especialidad.nombre
      }
    }
  end
end
