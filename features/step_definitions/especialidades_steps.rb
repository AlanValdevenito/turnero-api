Dado('el sistema no tiene registrado a la especialidad {string}') do |especialidad|
  @response = Faraday.get('/especialidades')
  especialidades = JSON.parse(@response.body)
  encontrado = especialidades.any? do |e|
    e['nombre'] == especialidad
  end
  expect(encontrado).to be false
end

Cuando('doy de alta a la especialidad {string}') do |especialidad|
  request_body = { nombre: especialidad, duracion_de_turnos: 10 }.to_json
  @response = Faraday.post('/especialidades', request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

Entonces('la especialidad {string} está registrada en el sistema') do |especialidad|
  @response = Faraday.get('/especialidades')
  especialidades = JSON.parse(@response.body)
  encontrado = especialidades.any? do |m|
    m['nombre'] == especialidad
  end
  expect(encontrado).to be true
end
