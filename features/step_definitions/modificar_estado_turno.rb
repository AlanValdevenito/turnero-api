Dado('hay un turno en el futuro') do
  turno = {
    matricula: 'ABC123',
    fecha: '2025-11-03',
    hora: '11:00',
    telegram_id: @paciente_telegram_id
  }
  response = Faraday.post('/turnos', turno.to_json, { 'Content-Type' => 'application/json' })
  json = JSON.parse(response.body)
  puts json
  expect(response.status).to eq(201)
  @turno_id = json['id']
end

Dado('tiene estado {string}') do |estado|
  response = Faraday.get("/turnos/pacientes/#{@paciente_email}")
  expect(response.body).to include(estado)
end

Dado('el hospital intenta pasar a {string} el turno') do |estado|
  params = { estado: }
  @response = Faraday.put("/turnos/#{@turno_id}", params.to_json, { 'Content-Type' => 'application/json' })

  expect(@response.status).to eq(200)
end

Entonces('el turno queda con estado {string}') do |estado|
  response = Faraday.get("/turnos/pacientes/#{@paciente_email}")
  expect(response.body).to include(estado)
end

Entonces('recibo un mensaje {string}') do |mensaje|
  json_response = JSON.parse(@response.body)
  expect(json_response['mensaje']).to eq(mensaje)
  expect(@response.status).to eq(200)
end
