Dado('que nunca reserve un turno') do
  # Nada
end

Cuando('quiero ver mi historial de turnos') do
  @response = Faraday.get("/turnos/pacientes/historial/#{@email}")
  @turnos = JSON.parse(@response.body)
end

Entonces('se muestra el mensaje {string}') do |mensaje|
  expect(@response.status).to eq(400)
  expect(@response.body).to include(mensaje)
end

Dado('que para la fecha {string} reserve 1 turno con el médico con matrícula {string} siendo hoy {string}') do |fecha_turno, matricula, fecha_actual|
  allow_any_instance_of(ProveedorDia).to receive(:hoy).and_return(Date.parse(fecha_actual))

  request_body = { matricula:, fecha: fecha_turno, hora: '09:00', email: @email }.to_json
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

Dado('cancele el turno') do
  params = { estado: 'Cancelado' }
  @response = Faraday.put("/turnos/#{@turno_id}", params.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Entonces('puedo ver mi turno con el médico {string} de la especialidad {string} con estado {string}') do |medico, especialidad, estado|
  @response = Faraday.get("/turnos/pacientes/historial/#{@email}")
  @turnos = JSON.parse(@response.body)

  encontrado = @turnos.any? do |turno|
    turno['medico'] == medico && turno['especialidad'] == especialidad && turno['estado'] == estado
  end

  expect(encontrado).to be true
end

Dado('que reserve {int} turnos a los cuales asisti') do |cantidad_turnos|
  cantidad_turnos.times do |i|
    minuto = (i + 1).to_s.rjust(2, '0')
    hora = "09:#{minuto}"

    request_body = { matricula: @matricula, fecha: '2025-06-05', hora:, email: @email }.to_json
    @response = Faraday.post('/turnos', request_body, { 'Content-Type' => 'application/json' })
    @turno_id = JSON.parse(@response.body)['id']

    params = { estado: 'Asistido' }
    @response = Faraday.put("/turnos/#{@turno_id}", params.to_json, { 'Content-Type' => 'application/json' })
  end
end

Entonces('puedo ver los {int} turnos que ya pasaron más cercanos a la fecha actual ordenados por fecha desde el mas reciente al mas antiguo') do |cantidad_turnos_visibles|
  fechas = @turnos.map { |t| DateTime.parse((t['fecha y hora']).to_s) }
  expect(fechas.length).to eq(cantidad_turnos_visibles)
  expect(fechas).to eq(fechas.sort.reverse)
end
