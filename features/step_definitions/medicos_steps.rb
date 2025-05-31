Dado('el sistema no tiene registrado al médico {string} con matricula {string}') do |nombre, _matricula|
  nombre, apellido = nombre.split
  @response = Faraday.get('/medicos')
  parsed_response = JSON.parse(@response.body)
  medicos = parsed_response['medicos']
  expect(medicos).not_to include(
    'nombre' => nombre,
    'apellido' => apellido
  )
end

Cuando('doy de alta al médico {string} de {string} con matricula {string}') do |nombre, especialidad, matricula|
  nombre, apellido = nombre.split
  request_body = { nombre:, apellido:, matricula:, especialidad: }.to_json
  @response = Faraday.post('/medicos', request_body, { 'Content-Type' => 'application/json' })
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
  medicos = parsed_response['medicos']
  expect(medicos).to include(
    'nombre' => nombre,
    'apellido' => apellido
  )
end
