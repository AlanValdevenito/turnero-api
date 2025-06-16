Dado('que el medico tiene {int} turnos') do |int|
end

Cuando('quiero dar de baja al medico') do
  response = Faraday.delete("/medicos/#{@matricula}")
  expect(response.status).to eq(200)
end

Entonces('no hay turnos correspondientes al medico') do
  response = Faraday.get("/turnos/medicos/#{@matricula}")

  puts JSON.parse(response.body)
  expect(JSON.parse(response.body)['error']).to eq("Paciente con email #{@email} inexistente")
end

Entonces('el medico ya no esta dado de alta') do
end
