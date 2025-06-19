Dado('que el medico tiene {int} turnos') do |cantidad_turnos|
  medico = RepositorioMedicos.new.buscar_por_matricula(@matricula)
  usuario = RepositorioUsuarios.new.buscar_por_email(@email)
  fecha = Date.parse('2025-06-18')
  cantidad_turnos.times do |n|
    turno = Turno.new(medico, usuario, fecha + n)
    RepositorioTurnos.new.save(turno)
  end
end

Cuando('quiero dar de baja al medico') do
  @response = api_delete("/medicos/#{@matricula}")
  expect(@response.status).to eq(200)
end

Entonces('no hay turnos correspondientes al medico') do
  expect(RepositorioTurnos.new.all).to be_empty
  expect(RepositorioMedicos.new.buscar_por_matricula(@matricula)).to be_nil
end

Entonces('el medico ya no esta dado de alta') do
  response = api_get("/turnos/medicos/#{@matricula}")
  expect(JSON.parse(response.body)['error']).to eq("Medico con matricula #{@matricula} inexistente")
end

Cuando('quiero dar de baja un medico inexistente') do
  matricula_medico_inexistente = 'matriculaInexistente'
  @response = api_delete("/medicos/#{matricula_medico_inexistente}")
end
