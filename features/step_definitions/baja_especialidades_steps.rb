Dado('que la especialidad tiene {int} medicos') do |_cantidad_medicos|
end

Cuando('quiero dar de baja la especialidad') do
  @response = api_delete("/especialidades/#{@especialidad}")
  expect(@response.status).to eq(200)
end

Entonces('no hay turnos correspondientes a la especialidad') do
  expect(RepositorioEspecialidades.new.buscar_por_nombre(@matricula)).to be_nil
end

Entonces('la especialidad ya no esta dada de alta') do
  response = api_get("/especialidades/#{@matricula}")
  expect(response.status).to eq(404)
end
