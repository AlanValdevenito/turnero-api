Dado('existe el paciente con email {string}') do |email|
  request_body = { email:, telegram_id: 345_634_634 }.to_json
  @response = Faraday.post('/usuarios', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Dado('el médico {string} con matrícula {string} de la especialidad {string} dado de alta') do |medico, matricula, especialidad|
  nombre, apellido = medico.split
  request_body = { nombre:, apellido:, matricula:, especialidad: }.to_json
  @response = Faraday.post('/medicos', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Dado('el médico con matrícula {string} tiene {int} turnos') do |matricula, cantidad_turnos|
  # Nada
end

Cuando('consulto los turnos del médico con matrícula {string}') do |matricula|
  @response = Faraday.get("/turnos/#{matricula}")
  @turnos = JSON.parse(@response.body)
  expect(@response.status).to eq(200)
end
