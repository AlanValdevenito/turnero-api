Dado('hay {int} paciente registrado') do |_cantidad_pacientes|
  @email = 'usuario@gmail.com'
  request_body = { email: @email, telegram_id: 345_634_634 }.to_json
  @response = Faraday.post('/usuarios', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Dado('la especialidad {string} dada de alta') do |especialidad|
  request_body = { nombre: especialidad, duracion_de_turnos: 10 }.to_json
  @response = Faraday.post('/especialidades', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Dado('el medico {string} de {string} dado de alta') do |apellido, especialidad|
  request_body = { nombre: 'Juan', apellido:, matricula: 'ABC123', especialidad: }.to_json
  @response = Faraday.post('/medicos', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Dado('el paciente tiene {int} turnos') do |cantidad_turnos|
  # Nada
end

Cuando('pido ver turnos del paciente') do
  @response = Faraday.get("/turnos/#{@email}")
  @turnos = JSON.parse(@response.body)
  expect(@response.status).to eq(200)
end

Entonces('debería ver una lista con {int} turnos') do |cantidad_turnos|
  expect(@turnos.size).to eq(cantidad_turnos)
end
