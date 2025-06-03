Dado('el usuario pide un turno') do
  @response = Faraday.get('/turnos/medicos-disponibles')
  expect(@response.status).to eq(200)
end

Entonces('se retorna un listado numerado de {int} médicos con nombre, apellido, matricula') do |int|
  json_response = JSON.parse(@response.body)
  expect(json_response.size).to eq(int)
  json_response.each do |medico|
    expect(medico).to have_key('nombre')
    expect(medico).to have_key('apellido')
    expect(medico).to have_key('matricula')
  end
end

Cuando('el usuario selecciona un médico de la lista') do
  @response = Faraday.get('/turnos/1/disponibilidad')
  expect(@response.status).to eq(200)
end

Entonces('se retornan los próximos {int} turnos disponibles del médico dentro de los próximos {int} meses') do |turnos, _meses|
  json_response = JSON.parse(@response.body)
  expect(json_response.size).to eq(turnos)
  json_response.each do |turno|
    expect(turno).to have_key('fecha')
    expect(turno).to have_key('hora')
  end
end

Cuando('el usuario selecciona un turno') do
  request_body = { medico_id: 1, fecha_hora: '2023-10-01T10:00:00Z', telegram_id: 123_456_789 }.to_json
  @response = Faraday.get('/turnos', request_body, { 'Content-Type' => 'application/json' })
end

Entonces('se reserva exitosamente con el mensaje {string}') do |mensaje|
  expect(@response.status).to eq(200)
  expect(@response.body).to include(mensaje)
end

Entonces('se muestra la información del turno: fecha y médico') do
  json_response = JSON.parse(@response.body)
  expect(json_response).to have_key('fecha')
  expect(json_response).to have_key('medico')
end
