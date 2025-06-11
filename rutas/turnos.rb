require_relative '../dominio/excepciones/turno_no_encontrado_exception'
require_relative '../dominio/excepciones/estado_invalido_exception'
require_relative '../dominio/excepciones/no_hay_historial_turnos_exception'
require_relative '../dominio/excepciones/turno_pasado_exception'

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

get '/turnos/pacientes/historial/:telegram_id' do
  logger.debug("GET /turnos/pacientes/historial/:telegram_id: #{params}")
  telegram_id = params[:telegram_id]
  respuesta = []

  begin
    turnos = turnero.historial_turnos_paciente(telegram_id)
    turnos.map do |e|
      respuesta << {
        'id': e.id,
        'fecha y hora': "#{e.fecha} #{e.hora}",
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

put '/turnos/:id' do
  logger.debug("PUT /turnos/:id: #{@params}")
  begin
    id = params['id']
    estado = @params[:estado]
    turno = turnero.modificar_estado_turno(id, estado)
    status 200
    json({ mensaje: "Turno actualizado: estado #{turno.estado}" })
  rescue TurnoYaPasadoException
    status 400
    json({ mensaje: 'No se puede cancelar un turno ya pasado' })
  rescue TurnoFuturoException
    status 400
    json({ mensaje: "No se puede marcar como #{estado} un turno futuro" })
  rescue TurnoNoEncontradoException
    status 404
    json({ mensaje: 'Turno no encontrado' })
  rescue EstadoNoPermitidoException
    status 409
    json({ mensaje: 'No se puede cambiar el estado de un turno que no este pendiente' })
  rescue EstadoInvalidoException
    status 400
    json({ mensaje: 'Estado inválido para el turno' })
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
