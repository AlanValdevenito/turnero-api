def crear_medicos_disponibles
  response = Faraday.get('/turnos/medicos-disponibles')
  if JSON.parse(response.body).size < 7
    especialidad = { nombre: 'Cardiologia', duracion_turno: 20 }
    Faraday.post('/especialidades', especialidad.to_json, { 'Content-Type' => 'application/json' })

    (1..7).each do |i|
      medico = {
        nombre: "Nombre#{i}",
        apellido: "Apellido#{i}",
        matricula: i,
        especialidad: 'Cardiologia'
      }
      Faraday.post('/medicos', medico.to_json, { 'Content-Type' => 'application/json' })
    end
  end
end

Dado('el usuario pide un turno') do
  crear_medicos_disponibles
  @response = Faraday.get('/turnos/medicos-disponibles')
  expect(@response.status).to eq(200)
end

Entonces('se retorna un listado numerado de {int} médicos con nombre, apellido, matricula, especialidad') do |int|
  json_response = JSON.parse(@response.body)
  expect(json_response.size).to eq(int)
  json_response.each do |medico|
    expect(medico).to have_key('nombre')
    expect(medico).to have_key('apellido')
    expect(medico).to have_key('matricula')
    expect(medico).to have_key('especialidad')
  end
end

Cuando('el usuario selecciona un médico de la lista') do
  especialidad = Especialidad.new('Cardiologia', 20)
  RepositorioEspecialidades.new.save(especialidad)

  medico = Medico.new('Michael', 'Jackson', '1', especialidad)
  RepositorioMedicos.new.save(medico)

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
  @response = Faraday.post('/turnos', request_body, { 'Content-Type' => 'application/json' })
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
