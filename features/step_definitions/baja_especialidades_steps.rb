Dado('que la especialidad tiene {int} medicos') do |_cantidad_medicos|
end

Dado('el otro médico {string} con matrícula {string} de la especialidad {string} dado de alta') do |medico, matricula, especialidad|
  nombre, apellido = medico.split
  @matricula2 = matricula
  request_body = { nombre:, apellido:, matricula:, especialidad: }.to_json
  @response = api_post('/medicos', request_body)
  expect(@response.status).to eq(200)
end

Dado('que la especialidad tiene dos medicos') do
  medico = RepositorioMedicos.new.buscar_por_matricula(@matricula)
  medico2 = RepositorioMedicos.new.buscar_por_matricula(@matricula2)
  usuario = RepositorioUsuarios.new.buscar_por_email(@email)
  fecha = Date.parse('2025-06-18')
  RepositorioTurnos.new.save(Turno.new(medico, usuario, fecha))
  RepositorioTurnos.new.save(Turno.new(medico2, usuario, fecha))
end

Cuando('quiero dar de baja la especialidad') do
  @response = api_delete("/especialidades/#{@especialidad}")
  expect(@response.status).to eq(200)
end

Entonces('no hay turnos correspondientes a la especialidad') do
  expect(RepositorioTurnos.new.all).to be_empty
  expect(RepositorioEspecialidades.new.buscar_por_nombre(@matricula)).to be_nil
end

Entonces('la especialidad ya no esta dada de alta') do
  response = api_get("/especialidades/#{@matricula}")
  expect(response.status).to eq(404)
end

Entonces('los medicos de la especialidad ya no estan dados de alta') do
  medico = RepositorioMedicos.new.buscar_por_matricula(@matricula)
  expect(medico).to be_nil
  medico2 = RepositorioMedicos.new.buscar_por_matricula(@Matricula2)
  expect(medico2).to be_nil
end
