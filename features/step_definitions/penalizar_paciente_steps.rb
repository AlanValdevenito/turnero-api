require 'faraday'
require 'json'

ESTADOS_VALIDOS = {
  'pendiente' => 'Pendiente',
  'ausente' => 'Ausente',
  'cancelado' => 'Cancelado',
  'asistido' => 'Asistido'
}.freeze

MENSAJE_DE_PENALIZACION = 'Penalización por porcentaje de asistencia abajo del 80%'.freeze

Dado('un paciente con email {string} registrado') do |email|
  telegram_id = rand(100_000..999_999)
  usuario_hash = { email:, telegram_id: }
  Faraday.post('usuarios', usuario_hash.to_json, { 'Content-Type' => 'application/json' })
  @paciente_email = email
  @paciente_telegram_id = telegram_id
end

Dado('la fecha y hora actual es {string} {string}') do |fecha, hora|
  @fecha_actual = Date.parse(fecha)
  @hora_mock = Time.parse("#{fecha} #{hora}")
  allow_any_instance_of(ProveedorHora).to receive(:ahora).and_return(@hora_mock)
end

Dado(/^que el paciente tuvo (\d+) turnos: (.+)$/) do |_total, lista|
  raise 'Debes definir la fecha actual con el step correspondiente' unless @fecha_actual

  estados = []
  lista.split(/, | y /).each do |parte|
    next unless parte =~ /(\d+) (\w+)/

    cantidad = Regexp.last_match(1).to_i
    estado = ESTADOS_VALIDOS.fetch(Regexp.last_match(2).downcase) { raise "Estado inválido: #{Regexp.last_match(2)}" }
    cantidad.times { estados << estado }
  end
  fecha_pasada = @fecha_actual - estados.count { |e| e != 'Pendiente' }
  fecha_futura = @fecha_actual + 1

  repo_turnos = RepositorioTurnos.new

  medico = RepositorioMedicos.new.buscar_por_matricula('ABC123')
  usuario = RepositorioUsuarios.new.buscar_por_email(@paciente_email)

  estados.each do |estado|
    fecha_turno =
      if estado == 'Pendiente'
        fecha_futura.tap { fecha_futura += 1 }
      else
        fecha_pasada.tap { fecha_pasada += 1 }
      end

    turno = Turno.crear(medico, usuario, fecha_turno.strftime('%Y-%m-%d'), '10:00')
    turno.estado = estado
    repo_turnos.save(turno)
  end
end

Cuando('intenta reservar un nuevo turno') do
  @dias_para_nuevo_turno ||= 100
  fecha_turno = @fecha_actual + @dias_para_nuevo_turno
  @dias_para_nuevo_turno += 1

  turno_hash = {
    matricula: 'ABC123',
    fecha: fecha_turno.strftime('%Y-%m-%d'),
    hora: '10:00',
    email: @paciente_email
  }
  @response = Faraday.post('turnos', turno_hash.to_json, { 'Content-Type' => 'application/json' })

  # Si la respuesta es penalización, guardamos y mockeamos la hora de penalización
  if @response.status == 400
    @hora_de_penalizacion = @hora_mock
    allow_any_instance_of(ProveedorHora).to receive(:ahora).and_return(@hora_de_penalizacion)
  end
end

Entonces('puede hacerlo exitosamente') do
  expect(@response.status).to eq(201)
  body = JSON.parse(@response.body)
  expect(body['message']).to eq('El turno se reservó exitosamente')
end

Entonces('debe mostrarse un mensaje de penalización') do
  expect(@response.status).to eq(400)
  body = JSON.parse(@response.body)
  expect(body['error']).to match(MENSAJE_DE_PENALIZACION)
end

Entonces('no puede reservar turnos por los próximos {int} minutos') do |minutos|
  raise 'No hay hora de penalización definida' unless @hora_de_penalizacion

  hora_mock = @hora_de_penalizacion + (minutos * 60) - 1 # justo antes de que termine la penalización
  allow_any_instance_of(ProveedorHora).to receive(:ahora).and_return(hora_mock)

  @dias_para_nuevo_turno ||= 100
  fecha_turno = @fecha_actual + @dias_para_nuevo_turno
  @dias_para_nuevo_turno += 1

  turno_hash = {
    matricula: 'ABC123',
    fecha: fecha_turno.strftime('%Y-%m-%d'),
    hora: '12:00',
    email: @paciente_email
  }
  response = Faraday.post('turnos', turno_hash.to_json, { 'Content-Type' => 'application/json' })

  expect(response.status).to eq(400)
  body = JSON.parse(response.body)
  expect(body['error']).to match(MENSAJE_DE_PENALIZACION)
end

Dado('que el paciente fue penalizado por bajo porcentaje') do
  # Simula que el paciente ya fue penalizado en este instante
  @hora_de_penalizacion = @hora_mock
  allow_any_instance_of(ProveedorHora).to receive(:ahora).and_return(@hora_de_penalizacion)

  usuario = RepositorioUsuarios.new.buscar_por_email(@paciente_email)
  usuario.ultima_penalizacion = @hora_de_penalizacion.to_datetime
  usuario.penalizable = false
  RepositorioUsuarios.new.save(usuario)
end

Dado('han pasado {int} minutos desde su último intento') do |minutos|
  # Avanza el tiempo simulado la cantidad de minutos indicada
  raise 'No hay hora de penalización definida' unless @hora_de_penalizacion

  nueva_hora = @hora_de_penalizacion + (minutos * 60)
  allow_any_instance_of(ProveedorHora).to receive(:ahora).and_return(nueva_hora)
end

Dado('saco un turno exitosamente') do
  @dias_para_nuevo_turno ||= 100
  fecha_turno = @fecha_actual + @dias_para_nuevo_turno
  @dias_para_nuevo_turno += 1

  turno_hash = {
    matricula: 'ABC123',
    fecha: fecha_turno.strftime('%Y-%m-%d'),
    hora: '10:00',
    email: @paciente_email
  }
  @response = Faraday.post('turnos', turno_hash.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Cuando('el estado del turno Pendiente se cambia a Ausente') do
  usuario = RepositorioUsuarios.new.buscar_por_email(@paciente_email)
  turno = RepositorioTurnos.new.buscar_por_usuario(usuario).select { |t| t.estado == 'Pendiente' }.last
  raise 'No hay turno pendiente para marcar como Ausente' unless turno

  # Avanza el tiempo simulado a después del turno
  nueva_hora = turno.fecha_hora + 60 # 1 minuto después del turno
  allow_any_instance_of(ProveedorHora).to receive(:ahora).and_return(nueva_hora)
  allow_any_instance_of(ProveedorDia).to receive(:hoy).and_return(nueva_hora.to_date)

  body = { estado: 'Ausente' }.to_json
  response = Faraday.put("turnos/#{turno.id}", body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(200)
end
