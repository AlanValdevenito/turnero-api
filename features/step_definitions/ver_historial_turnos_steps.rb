Dado('que nunca reserve un turno') do
  # Nada
end

Cuando('quiero ver mi historial de turnos') do
  @response = Faraday.get("/turnos/pacientes/historial/#{@telegram_id}")
  @turnos = JSON.parse(@response.body)
end

Entonces('se muestra el mensaje {string}') do |mensaje|
  expect(@response.status).to eq(400)
  expect(@response.body).to include(mensaje)
end

Dado('que reserve {int} turno con el médico {string} con matrícula {string} de la especialidad {string}') do |_cantidad_turnos, _medico_nombre, matricula, _especialidad|
  request_body = { matricula:, fecha: '2025-03-06', hora: '09:00', telegram_id: @telegram_id }.to_json
  @response = Faraday.post('/turnos', request_body, { 'Content-Type' => 'application/json' })
  @turno_id = JSON.parse(@response.body)['id']
  expect(@response.status).to eq(201)
end

Dado('no asisti al turno') do
  params = { estado: 'Ausente' }
  @response = Faraday.put("/turnos/#{@turno_id}", params.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Dado('asisti al turno') do
  params = { estado: 'Asistido' }
  @response = Faraday.put("/turnos/#{@turno_id}", params.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Entonces('puedo ver mi turno con el médico {string} de la especialidad {string} con estado {string}') do |medico, especialidad, estado|
  @response = Faraday.get("/turnos/pacientes/historial/#{@telegram_id}")
  @turnos = JSON.parse(@response.body)

  encontrado = @turnos.any? do |turno|
    turno['medico'] == medico && turno['especialidad'] == especialidad && turno['estado'] == estado
  end

  expect(encontrado).to be true
end
