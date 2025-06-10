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
  crear_medico(nombre:, apellido:, matricula:, especialidad:)
end

Dado('la fecha actual es {string}') do |fecha|
  allow_any_instance_of(ProveedorDia).to receive(:hoy).and_return(Date.parse(fecha))
  @fecha_actual = Date.parse(fecha)
end

Dado('el paciente tiene {int} turno con estado {string} con el médico {string} matricula {string} de la especialidad {string}') do |cantidad, estado, _medico_nombre, matricula, _especialidad|
  raise 'Debes definir la fecha actual con el step correspondiente' unless @fecha_actual

  # TODO: POR AHORA NO SE PUEDE CAMBIAR EL ESTADO DEL TURNO, SE DEBE CREAR CON EL ESTADO QUE SE QUIERA
  # O PODER CAMBIARLO DESDE LA API -> POR ESO USO REPOSITORIOS
  usuario = RepositorioUsuarios.new.buscar_por_telegram_id(@paciente_telegram_id)
  medico = RepositorioMedicos.new.buscar_por_matricula(matricula)
  repo_turnos = RepositorioTurnos.new

  cantidad.times do
    fecha_hora = DateTime.parse("#{@fecha_actual + 1}T10:00:00")
    turno = Turno.new(medico, usuario, fecha_hora, estado)
    repo_turnos.save(turno)
  end
end

Cuando('solicito los proximos turnos del paciente') do
  get "/turnos/pacientes/telegram/#{@paciente_telegram_id}/proximos"
  @response = last_response
end

Entonces('recibo un listado de sus próximos turnos con {int} turno') do |cantidad|
  body = JSON.parse(@response.body)
  puts "Respuesta de la API: #{body.inspect}"
  expect(body.size).to eq(cantidad)
end

Entonces('tiene al medico {string} de la especialidad {string}') do |nombre, especialidad|
  body = JSON.parse(@response.body)
  expect(body.any? { |t| t['medico'] == nombre && t['especialidad'] == especialidad }).to be true
end

Entonces('recibo un mensaje de error {string}') do |mensaje_error|
  expect(@response.status).to eq(400)
  body = JSON.parse(@response.body)
  expect(body['mensaje']).to eq(mensaje_error)
end

Dado('el paciente tiene {int} turno con estado {string} con el médico matricula {string} para la fecha {string}') do |cantidad, _estado, matricula, fecha|
  raise 'Debes definir la fecha actual con el step correspondiente' unless @fecha_actual

  cantidad.times do
    turno_hash = {
      matricula:,
      fecha:,
      hora: '10:00',
      telegram_id: @paciente_telegram_id
    }
    response = Faraday.post('/turnos', turno_hash.to_json, { 'Content-Type' => 'application/json' })
    puts "Respuesta al crear turno: #{response.body}"
  end
end

Entonces('tiene el turno para la fecha {string} con el médico {string} de la especialidad {string}') do |fecha, medico, especialidad|
  body = JSON.parse(@response.body)
  expect(
    body.any? do |t|
      t['fecha y hora'].start_with?(fecha) && t['medico'] == medico && t['especialidad'] == especialidad
    end
  ).to be true
end
