Dado('que para la fecha {string} reserve {int} turno con el medico con matricula {string} siendo hoy {string}') do |fecha_turno, _cantidad_turnos, matricula, fecha_hoy|
  @matricula = matricula
  @fecha_turno = fecha_turno
  @fecha_hoy = fecha_hoy
  allow_any_instance_of(ProveedorDia).to receive(:hoy).and_return(Date.parse(fecha_hoy))
  anio, mes, dia = fecha_hoy.split('-')
  allow_any_instance_of(ProveedorHora).to receive(:ahora).and_return(Time.local(anio, mes, dia, 8, 0, 0))
  medico = RepositorioMedicos.new.buscar_por_matricula(matricula)
  usuario = RepositorioUsuarios.new.buscar_por_email(@email)
  turno = Turno.new(medico, usuario, Date.parse(fecha_turno), 'Pendiente')
  @id = RepositorioTurnos.new.save(turno).id
end

Dado('consulto mis turnos') do
  response = Faraday.get("/turnos/pacientes/proximos/#{@email}")
  @turno = JSON.parse(response.body).first
  expect(@turno).to have_key('proximas_24hs')
end

Cuando('pido cancelar el turno') do
  request_body = { proximas_24hs: @turno['proximas_24hs'] }.to_json
  @response = Faraday.put("/turnos/#{@turno['id']}/cancelacion", request_body, { 'Content-Type' => 'application/json' })
end

Entonces('devuelve el mensaje {string}') do |mensaje|
  expect(JSON.parse(@response.body)['mensaje']).to include mensaje
end

Cuando('pido cancelar un turno con un id inexistente') do
  id_inexistente = 100
  request_body = { proximas_24hs: @turno['proximas_24hs'] }.to_json
  @response = Faraday.put("/turnos/#{id_inexistente}/cancelacion", request_body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(404)
end

Cuando('pido cancelar el turno de otro paciente') do
  allow_any_instance_of(ProveedorDia).to receive(:hoy).and_return(Date.parse(@fecha_hoy))
  anio, mes, dia = @fecha_hoy.split('-')
  allow_any_instance_of(ProveedorHora).to receive(:ahora).and_return(Time.local(anio, mes, dia, 8, 0, 0))
  usuario = Usuario.new('otroUsuario@mail.com')
  RepositorioUsuarios.new.save(usuario)
  medico = RepositorioMedicos.new.buscar_por_matricula(@matricula)
  turno = Turno.new(medico, usuario, Date.parse(@fecha_turno), 'Pendiente')
  id_turno_otro_paciente = RepositorioTurnos.new.save(turno).id
  request_body = { proximas_24hs: @turno['proximas_24hs'] }.to_json
  response = Faraday.put("/turnos/#{id_turno_otro_paciente}/cancelacion", request_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq(403)
end
