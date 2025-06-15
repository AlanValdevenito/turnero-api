Dado('que el usuario pide un turno por especialidad') do
  @response = Faraday.get('/especialidades')
  expect(@response.status).to eq(200)
end

Entonces('se muestra un listado de todas las especialidades con su con nombre') do
  json_response = JSON.parse(@response.body)
  json_response.each do |especialidad|
    expect(especialidad).to have_key('nombre')
  end
end

Cuando('el usuario selecciona la especialidad {string}') do |especialidad|
  @response = Faraday.get("/turnos/medicos-disponibles/#{especialidad}")
end

Entonces('se muestra un listado de {int} médico de la especialidad {string} con su nombre y apellido') do |cantidad_medicos, especialidad|
  json_response = JSON.parse(@response.body)
  @matricula = json_response.first['matricula']
  expect(json_response.size).to eq(cantidad_medicos)
  json_response.each do |medico|
    expect(medico['especialidad']).to eq(especialidad)
    expect(medico).to have_key('nombre')
    expect(medico).to have_key('apellido')
  end
end

Cuando('el usuario selecciona un medico') do
  @response = Faraday.get("/turnos/#{@matricula}/disponibilidad")
  expect(@response.status).to eq(200)
end

Cuando('el usuario selecciona el turno con el medico de matricula {string}') do |matricula|
  turno_seleccionado = JSON.parse(@response.body).first

  body = { matricula:, fecha: turno_seleccionado['fecha'], hora: turno_seleccionado['hora'], email: @email }

  @response = Faraday.post('/turnos', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Entonces('se muestra el mensaje de exito {string}') do |mensaje|
  @turno = JSON.parse(@response.body)
  expect(@turno['message']).to eq(mensaje)
end

Entonces('se muestra la fecha, hora, medico y especialidad del turno reservado') do
  expect(@turno).to have_key('fecha')
  expect(@turno).to have_key('medico')
  expect(@turno['medico']).to have_key('especialidad')
end

Entonces('se muestra un error {int}') do |codigo_error|
  expect(@response.status).to eq(codigo_error)
end

Entonces('se muestra el mensaje de error {string}') do |mensaje_error|
  expect(JSON.parse(@response.body)['error']).to eq(mensaje_error)
end
