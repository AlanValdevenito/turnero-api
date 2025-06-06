Dado('existe el paciente con email {string}') do |email|
  @telegram_id = 345_634_634
  request_body = { email:, telegram_id: @telegram_id }.to_json
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

Dado('el médico con matrícula {string} tiene un turno {string} con el paciente {string} para la fecha {string} durante el horario {string}') do |matricula, _estado_del_turno, _email, fecha, hora|
  request_body = { matricula:, fecha:, hora:, telegram_id: @telegram_id }.to_json
  @response = Faraday.post('/turnos', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Entonces('deberia ver el id del turno') do
  encontrado = @turnos.any? do |turno|
    turno['id'] == JSON.parse(@response.body)[:id]
  end
  expect(encontrado).to be true
end

Entonces('deberia ver el estado {string}, paciente {string}, email {string}, fecha {string} y hora {string}') do |estado, paciente, email, fecha, hora|
  encontrado = @turnos.any? do |turno|
    turno['paciente'] == paciente && turno['email'] == email && turno['estado'] == estado && turno['fecha'] == fecha && turno['hora'] == hora
  end
  expect(encontrado).to be true
end
