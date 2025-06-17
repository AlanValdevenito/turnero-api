Dado('que el medico tiene {int} turnos') do |int|
end

Cuando('quiero dar de baja al medico') do
  @response = Faraday.delete("/medicos/#{@matricula}")
  expect(@response.status).to eq(200)
end

Entonces('no hay turnos correspondientes al medico') do
  expect(RepositorioMedicos.new.buscar_por_matricula(@matricula)).to be_nil
end

Entonces('el medico ya no esta dado de alta') do
  response = Faraday.get("/turnos/medicos/#{@matricula}")
  expect(JSON.parse(response.body)['error']).to eq("Medico con matricula #{@matricula} inexistente")
end
