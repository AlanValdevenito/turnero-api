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

get '/turnos/pacientes/telegram/:telegram_id/proximos' do
  logger.debug("GET /turnos/pacientes/telegram/:telegram_id/proximos: #{params}")
  telegram_id = params[:telegram_id]
  respuesta = []
  begin
    turnos = turnero.proximos_turnos_paciente(telegram_id)
    turnos.map do |e|
      respuesta << {
        id: e.id,
        'fecha y hora': e.fecha_hora.strftime('%Y-%m-%d %H:%M').to_s,
        especialidad: e.medico.especialidad.nombre,
        medico: "#{e.medico.nombre} #{e.medico.apellido}",
        estado: e.estado
      }
    end
    status 200
    json(respuesta)
  rescue NoHayProximosTurnosException
    status 400
    json({ mensaje: 'El paciente no tiene próximos turnos' })
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
    turno = crear_turno_desde_params(@params)
    status 201
    json(turno_a_json(turno))
  rescue UsuarioNoEncontradoException
    status 404
    json({ error: 'Usuario no encontrado' })
  rescue MedicoNoEncontradoException
    status 404
    json({ error: 'Médico no encontrado' })
  rescue FechaNoValidaException
    status 400
    json({ error: 'Fecha inválida para agendar un turno' })
  rescue TurnoYaExisteException
    status 400
    json({ error: 'Ya existe un turno para ese médico y fecha/hora' })
  end
end

helpers do
  def crear_turno_desde_params(params)
    turnero.crear_turno(params[:matricula], params[:fecha], params[:hora], params[:telegram_id])
  end

  def turno_a_json(turno)
    {
      message: 'El turno se reservó exitosamente',
      id: turno.id,
      fecha: turno.fecha,
      hora: turno.hora,
      medico: {
        nombre: turno.medico.nombre,
        apellido: turno.medico.apellido,
        matricula: turno.medico.matricula,
        especialidad: turno.medico.especialidad.nombre
      }
    }
  end
end
