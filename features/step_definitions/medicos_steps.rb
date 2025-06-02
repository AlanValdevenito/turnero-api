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

Entonces('veo el mensaje {string}') do |_mensaje|
  parsed_response = JSON.parse(@response.body)
  id = parsed_response['id']
  message = parsed_response['message']
  expect(id.to_i).to be > 0
  expect(message).to eq 'El médico fue dado de alta correctamente.'
end

Entonces('el médico {string} está registrado en el sistema') do |nombre|
  nombre, apellido = nombre.split
  @response = Faraday.get('/medicos')
  parsed_response = JSON.parse(@response.body)
  medicos = parsed_response
  puts medicos
  encontrado = medicos.any? do |medico|
    medico['nombre'] == nombre && medico['apellido'] == apellido
  end
  expect(encontrado).to be true
end
