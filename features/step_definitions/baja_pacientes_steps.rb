Dado('que el paciente tiene {int} turnos') do |_cantidad_turnos|
end

Cuando('quiero dar de baja al paciente') do
  @response = Faraday.delete("/pacientes/#{@email}")
  expect(@response.status).to eq(200)
end

Entonces('se muestra el mensaje de exitoo {string}') do |mensaje|
  expect(JSON.parse(@response.body)['message']).to eq(mensaje)
end

Entonces('no hay turnos correspondientes al paciente') do
  response = Faraday.get("/turnos/pacientes/#{@email}")
  expect(response.body['message']).to eq("Paciente con email #{@email} inexistente")
end

Entonces('el paciente no esta dado de alta') do
  response = Faraday.get("/turnos/pacientes/#{@email}")
  expect(response.status).to eq(404)
end

Cuando('quiero dar de baja un paciente inexistente') do
end

Entonces('se devuelve el error {string}') do |string|
end
