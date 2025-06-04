Dado('hay {int} paciente registrado') do |_cantidad_pacientes|
  @email = 'usuario@gmail.com'
  @usuario_telegram_id = 345_634_634

  request_body = { email: @email, telegram_id: @usuario_telegram_id }.to_json
  @response = Faraday.post('/usuarios', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Dado('la especialidad {string} dada de alta') do |especialidad|
  request_body = { nombre: especialidad, duracion_de_turnos: 10 }.to_json
  @response = Faraday.post('/especialidades', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Dado('el medico {string} de {string} dado de alta') do |apellido, especialidad|
  @medico_matricula = 'ABC123'

  request_body = { nombre: 'Juan', apellido:, matricula: @medico_matricula, especialidad: }.to_json
  @response = Faraday.post('/medicos', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Dado('el paciente tiene {int} turnos') do |cantidad_turnos|
  cantidad_turnos.times do |i|
    mes = (i + 1).to_s.rjust(2, '0')
    request_body = { matricula: @medico_matricula, fecha: "2025-#{mes}-01", hora: '15:50', telegram_id: @usuario_telegram_id }.to_json
    @response = Faraday.post('/turnos', request_body, { 'Content-Type' => 'application/json' })
    expect(@response.status).to eq(201)
  end
end

Cuando('pido ver turnos del paciente') do
  @response = Faraday.get("/turnos/#{@email}")
  @turnos = JSON.parse(@response.body)
  expect(@response.status).to eq(200)
end

Entonces('debería ver una lista con {int} turnos') do |cantidad_turnos|
  expect(@turnos.size).to eq(cantidad_turnos)
end

Dado('el paciente tiene {int} turno pendiente con el medico Perez de Traumatologia') do |cantidad_turnos|
  cantidad_turnos.times do |i|
    mes = (i + 1).to_s.rjust(2, '0')
    request_body = { matricula: @medico_matricula, fecha: "2025-#{mes}-01", hora: '15:50', telegram_id: @usuario_telegram_id }.to_json
    @response = Faraday.post('/turnos', request_body, { 'Content-Type' => 'application/json' })
    expect(@response.status).to eq(201)
  end
end

Entonces('deberia tener el estado {string}, medico {string} y especialidad {string}') do |estado, apellido_medico, especialidad|
  encontrado = @turnos.any? do |turno|
    turno['medico'].split.last == apellido_medico && turno['especialidad'] == especialidad && turno['estado'] == estado
  end
  expect(encontrado).to be true
end

Dado('el paciente {string} no está registrado') do |email|
  @response = Faraday.get('/usuarios')
  usuarios = JSON.parse(@response.body)
  encontrado = usuarios.any? do |usuario|
    usuario['email'] == email
  end
  expect(encontrado).to be false
end

Cuando('pido ver turnos del paciente {string}') do |email|
  @response = Faraday.get("/turnos/#{email}")
  @turnos = JSON.parse(@response.body)
end

Entonces('debería ver un error {int} con un mensaje {string}') do |error, mensaje|
  expect(@response.status).to eq(error)
  expect(@response.body).to include(mensaje)
end
