Dado('el sistema no tiene registrado a la especialidad {string}') do |especialidad|
  @response = api_get('/especialidades')
  especialidades = JSON.parse(@response.body)
  encontrado = especialidades.any? do |e|
    e['nombre'] == especialidad
  end
  expect(encontrado).to be false
end

Cuando('doy de alta a la especialidad {string}') do |especialidad|
  request_body = { nombre: especialidad, duracion_de_turnos: 10, limite_turnos_por_usuario: 5 }.to_json
  @response = api_post('/especialidades', request_body)
  expect(@response.status).to eq(200)
end

Entonces('la especialidad {string} está registrada en el sistema') do |especialidad|
  @response = api_get('/especialidades')
  especialidades = JSON.parse(@response.body)
  encontrado = especialidades.any? do |m|
    m['nombre'] == especialidad
  end
  expect(encontrado).to be true
end
