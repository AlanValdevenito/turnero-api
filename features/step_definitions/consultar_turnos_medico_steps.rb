Dado('existe el paciente con email {string}') do |email|
  @telegram_id = 345_634_634
  @email = email
  request_body = { email:, telegram_id: @telegram_id }.to_json
  @response = api_post('/usuarios', request_body)
  expect(@response.status).to eq(201)
end

Dado('el médico {string} con matrícula {string} de la especialidad {string} dado de alta') do |medico, matricula, especialidad|
  nombre, apellido = medico.split
  @matricula = matricula
  request_body = { nombre:, apellido:, matricula:, especialidad: }.to_json
  @response = api_post('/medicos', request_body)
  expect(@response.status).to eq(200)
end

Dado('el médico con matrícula {string} tiene {int} turnos') do |matricula, cantidad_turnos|
  # Nada
end

Cuando('consulto los turnos del médico con matrícula {string}') do |matricula|
  @response = api_get("/turnos/medicos/#{matricula}")
  @turnos = JSON.parse(@response.body)
end

Dado('el médico con matrícula {string} tiene un turno {string} con el paciente {string} para la fecha {string} durante el horario {string}') do |matricula, _estado_del_turno, email, fecha, hora|
  request_body = { matricula:, fecha:, hora:, email: }.to_json
  @response = api_post('/turnos', request_body)
  @id_turno = JSON.parse(@response.body)['id']
  expect(@response.status).to eq(201)
end

Entonces('deberia ver el id del turno') do
  encontrado = @turnos.any? do |turno|
    turno['id'] == @id_turno
  end
  expect(encontrado).to be true
end

Entonces('deberia ver el estado {string}, email del paciente {string}, fecha {string} y hora {string}') do |estado, paciente_email, fecha, hora|
  encontrado = @turnos.any? do |turno|
    turno['paciente_email'] == paciente_email && turno['estado'] == estado && turno['fecha'] == fecha && turno['hora'] == hora
  end
  expect(encontrado).to be true
end

Dado('el medico con matricula {string} no esta dado de alta') do |matricula|
  @response = api_get('/medicos')
  usuarios = JSON.parse(@response.body)
  encontrado = usuarios.any? do |usuario|
    usuario['matricula'] == matricula
  end
  expect(encontrado).to be false
end

Entonces('deberia ver un error {int}') do |error|
  expect(@response.status).to eq(error)
end

Entonces('el mensaje de error debe ser {string}') do |mensaje|
  expect(@response.body).to include(mensaje)
end

Dado('que el médico con matrícula {string} tiene {int} turnos') do |matricula, cant_turnos|
  medico = RepositorioMedicos.new.buscar_por_matricula(matricula)
  paciente = RepositorioUsuarios.new.buscar_por_telegram_id(@telegram_id)
  cant_turnos.downto(1) do |i|
    minuto = (i + 1).to_s.rjust(2, '0')
    fecha = DateTime.now.strftime('%Y-%m-%d')
    hora = "#{DateTime.now.hour}:#{minuto}"
    RepositorioTurnos.new.save(Turno.crear(medico, paciente, fecha, hora))
  end
end

Entonces('en orden desde el más reciente al más antiguo') do
  fechas = @turnos.map { |t| DateTime.parse("#{t['fecha']} #{t['hora']}") }
  expect(fechas).to eq(fechas.sort.reverse)
end
