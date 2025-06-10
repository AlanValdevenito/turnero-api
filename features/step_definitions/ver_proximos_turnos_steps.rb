require 'faraday'
require 'json'

def crear_medico(nombre:, apellido:, matricula:, especialidad:)
  especialidad_hash = { nombre: especialidad, duracion_de_turnos: 20 }
  Faraday.post('/especialidades', especialidad_hash.to_json, { 'Content-Type' => 'application/json' })
  medico_hash = {
    nombre:,
    apellido:,
    matricula:,
    especialidad:
  }
  Faraday.post('/medicos', medico_hash.to_json, { 'Content-Type' => 'application/json' })
end

def crear_paciente(email)
  telegram_id = rand(100_000..999_999)
  usuario_hash = { email:, telegram_id: }
  Faraday.post('/usuarios', usuario_hash.to_json, { 'Content-Type' => 'application/json' })
  [email, telegram_id]
end

Dado('el paciente {string} registrado') do |email|
  @paciente_email, @paciente_telegram_id = crear_paciente(email)
end

Dado('el médico {string} de la especialidad {string} con matricula {string} dado de alta') do |nombre_completo, especialidad, matricula|
  nombre, apellido = nombre_completo.split(' ', 2)
  crear_medico(nombre: nombre, apellido: apellido, matricula: matricula, especialidad: especialidad)
end

Dado('la fecha actual es {string}') do |fecha|
  allow_any_instance_of(ProveedorDia).to receive(:hoy).and_return(Date.parse(fecha))
  @fecha_actual = Date.parse(fecha)
end

Dado('el paciente tiene {int} turno con estado {string} con el médico {string} matricula {string} de la especialidad {string}') do |cantidad, estado, medico_nombre, matricula, especialidad|
  raise 'Debes definir la fecha actual con el step correspondiente' unless @fecha_actual

  cantidad.times do
    turno_hash = {
      matricula: matricula,
      fecha: (@fecha_actual + 1).to_s,
      hora: '10:00',
      telegram_id: @paciente_telegram_id
    }
    Faraday.post('/turnos', turno_hash.to_json, { 'Content-Type' => 'application/json' })
  end

  # necesito cambiar el estado del turno a lo que se pide
end

Cuando('solicito los proximos turnos del paciente') do
  get "/turnos/pacientes/telegram/#{@paciente_telegram_id}/proximos"
  @response = last_response
end

Entonces('recibo un listado de sus próximos turnos con {int} turno') do |cantidad|
  body = JSON.parse(@response.body)
  expect(body.size).to eq(cantidad)
end

Entonces('tiene al medico {string} de la especialidad {string}') do |nombre, especialidad|
  body = JSON.parse(@response.body)
  expect(body.any? { |t| t['medico'] == nombre && t['especialidad'] == especialidad }).to be true
end
