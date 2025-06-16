Dado('la especialidad {string} dada de alta con límite de {int} turnos') do |especialidad, limite|
  request_body = { nombre: especialidad, duracion_de_turnos: 20, limite_turnos_por_usuario: limite }.to_json
  @response = Faraday.post('/especialidades', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Dado('que el paciente con email {string} tiene {int} turnos pendientes en la especialidad {string}') do |email, cantidad, especialidad|
  @response = Faraday.get('/medicos')
  medicos = JSON.parse(@response.body)
  medico = medicos.find { |m| m['especialidad'] == especialidad }

  matricula = medico['matricula']

  cantidad.times do |i|
    dia = (i + 10).to_s.rjust(2, '0')

    request_body = {
      matricula:,
      fecha: "2025-07-#{dia}",
      hora: '15:00',
      email:
    }.to_json

    @response = Faraday.post('/turnos', request_body, { 'Content-Type' => 'application/json' })
    expect(@response.status).to eq(201)
  end

  @email = email
  @especialidad = especialidad
end

Dado('el limite de turnos en {string} es de {int}') do |especialidad, limite|
  @response = Faraday.get('/especialidades')

  especialidades = JSON.parse(@response.body)
  especialidad_encontrada = especialidades.find { |e| e['nombre'] == especialidad }

  expect(especialidad_encontrada['limite_turnos_por_usuario']).to eq(limite)
end

Cuando('solicita un nuevo turno en {string}') do |especialidad|
  @response = Faraday.get('/medicos')
  medicos = JSON.parse(@response.body)
  medico = medicos.find { |m| m['especialidad'] == especialidad }

  matricula = medico['matricula']
  @fecha = '2025-07-15'
  @hora = '17:00'
  request_body = {
    matricula:,
    fecha: @fecha,
    hora: @hora,
    email: @email
  }.to_json

  @response = Faraday.post('/turnos', request_body, { 'Content-Type' => 'application/json' })
end

Entonces('el turno es creado exitosamente') do
  expect(@response.status).to eq(201)
  response_body = JSON.parse(@response.body)
  expect(response_body['fecha']).to eq(@fecha)
  expect(response_body['hora']).to eq(@hora)
end

Entonces('el sistema rechaza la solicitud con el mensaje {string}') do |mensaje|
  expect(@response.status).to eq(422)
  response_body = JSON.parse(@response.body)
  expect(response_body['mensaje']).to eq(mensaje)
end
