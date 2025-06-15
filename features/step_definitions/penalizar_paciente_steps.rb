require 'faraday'
require 'json'

ESTADOS_VALIDOS = {
  'pendiente' => 'Pendiente',
  'ausente' => 'Ausente',
  'cancelado' => 'Cancelado',
  'asistido' => 'Asistido'
}.freeze

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
  repo_medicos = RepositorioMedicos.new
  repo_usuarios = RepositorioUsuarios.new

  medico = repo_medicos.buscar_por_matricula('ABC123')
  usuario = repo_usuarios.buscar_por_email(@paciente_email)

  estados.each do |estado|
    fecha_turno =
      if estado == 'Pendiente'
        fecha_futura.tap { fecha_futura += 1 }
      else
        fecha_pasada.tap { fecha_pasada += 1 }
      end

    turno = repo_turnos.save(Turno.crear(medico, usuario, fecha_turno.strftime('%Y-%m-%d'), '10:00'))
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
