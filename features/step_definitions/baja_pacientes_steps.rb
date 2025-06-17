Dado('que el paciente tiene {int} turnos') do |cantidad_turnos|
  medico = RepositorioMedicos.new.buscar_por_matricula(@matricula)
  usuario = RepositorioUsuarios.new.buscar_por_email(@email)
  fecha = Date.parse('2025-06-18')
  cantidad_turnos.times do |n|
    turno = Turno.new(medico, usuario, fecha + n)
    RepositorioTurnos.new.save(turno)
  end
end

Cuando('quiero dar de baja al paciente') do
  @response = api_delete("/pacientes/#{@email}")
  expect(@response.status).to eq(200)
end

Entonces('se muestra el mensaje de exitoo {string}') do |mensaje|
  expect(JSON.parse(@response.body)['message']).to eq(mensaje)
end

Entonces('no hay turnos correspondientes al paciente') do
  expect(RepositorioUsuarios.new.buscar_por_email(@email)).to be_nil
end

Entonces('el paciente no esta dado de alta') do
  response = api_get("/turnos/pacientes/#{@email}")
  expect(response.status).to eq(404)
end

Cuando('quiero dar de baja un paciente inexistente') do
  email_inexistente = 'email@inexistente.com'
  @response = api_delete("/pacientes/#{email_inexistente}")
end

Entonces('se devuelve el error {int}') do |error_code|
  expect(@response.status).to eq(error_code)
end
