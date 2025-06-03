Dado('la especialidad {string} ya esta dada de alta en el sistema') do |especialidad|
  request_body = { nombre: especialidad, duracion_de_turnos: 10 }.to_json
  @response = Faraday.post('/especialidades', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Dado('el sistema no tiene registrado al médico {string} con matricula {string}') do |nombre_completo, _matricula|
  nombre, apellido = nombre_completo.split
  @response = Faraday.get('/medicos')
  medicos = JSON.parse(@response.body)
  encontrado = medicos.any? do |medico|
    medico['nombre'] == nombre && medico['apellido'] == apellido
  end
  expect(encontrado).to be false
end

Cuando('doy de alta al médico {string} de {string} con matricula {string}') do |nombre, especialidad, matricula|
  nombre, apellido = nombre.split
  request_body = { nombre:, apellido:, matricula:, especialidad: }.to_json
  @response = Faraday.post('/medicos', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Entonces('veo el mensaje {string}') do |mensaje|
  respuesta_parseada = JSON.parse(@response.body)
  id = respuesta_parseada['id']
  respuesta = respuesta_parseada['message']
  expect(id.to_i).to be > 0
  expect(respuesta).to eq mensaje
end

Entonces('el médico {string} está registrado en el sistema') do |nombre|
  nombre, apellido = nombre.split
  @response = Faraday.get('/medicos')
  parsed_response = JSON.parse(@response.body)
  medicos = parsed_response
  encontrado = medicos.any? do |medico|
    medico['nombre'] == nombre && medico['apellido'] == apellido
  end
  expect(encontrado).to be true
end
