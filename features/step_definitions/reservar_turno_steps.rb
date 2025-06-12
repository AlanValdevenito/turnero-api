def crear_medicos_disponibles
  response = Faraday.get('/turnos/medicos-disponibles')
  if JSON.parse(response.body).size < 7
    especialidad = { nombre: 'Cardiologia', duracion_de_turnos: 20 }
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

def crear_usuario
  @usuario = Usuario.new('juan@mail.com', nil, 123_456_789)
  @repositorio_usuarios = RepositorioUsuarios.new
  @repositorio_usuarios.save(@usuario)
end

Dado('el usuario pide un turno') do
  crear_usuario
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

Entonces('se retornan los próximos {int} turnos disponibles del médico dentro de los próximos 2 meses') do |num_turnos|
  json_response = JSON.parse(@response.body)
  expect(json_response.size).to eq(num_turnos)
  json_response.each do |turno|
    expect(turno).to have_key('fecha')
    expect(turno).to have_key('hora')
  end
end

Cuando('el usuario selecciona un turno') do
  @turno_seleccionado = JSON.parse(@response.body).first
  @params = {
    matricula: '1',
    fecha: @turno_seleccionado['fecha'],
    hora: @turno_seleccionado['hora'],
    email: 'juan@mail.com'
  }
  @response = Faraday.post('/turnos', @params.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Entonces('se reserva exitosamente con el mensaje {string}') do |mensaje|
  expect(@response.status).to eq(201)
  expect(@response.body).to include(mensaje)
end

Entonces('se muestra la información del turno: fecha y médico') do
  json_response = JSON.parse(@response.body)
  expect(json_response).to have_key('fecha')
  expect(json_response).to have_key('medico')
end

Cuando('el médico no tiene turnos disponibles en los próximos 2 meses') do
  especialidad = Especialidad.new('Cardiologia', 30)
  RepositorioEspecialidades.new.save(especialidad)
  medico = Medico.new('Lucas', 'Martinez', '25', especialidad)
  RepositorioMedicos.new.save(medico)
  usuario = Usuario.new('pepe@pepito.com', nil, 123_456_789)
  RepositorioUsuarios.new.save(usuario)
  calculador = CalculadorDeDisponibilidad.new(ProveedorDia.new, ProveedorHora.new, ProveedorFeriados.new)

  allow_any_instance_of(ProveedorDia).to receive(:hoy).and_return(Date.parse('2025-06-17'))

  duracion = medico.especialidad.duracion_de_turnos
  fecha_inicio = Date.parse('2025-06-17')
  fecha_fin = fecha_inicio + 60

  (fecha_inicio...fecha_fin).each do |fecha|
    next unless calculador.dia_laboral?(fecha, [])

    tiempos_ocupados = Set.new
    turnos_del_dia = calculador.turnos_para_dia(fecha, duracion, tiempos_ocupados)
    turnos_del_dia.each do |fecha_hora|
      turno = Turno.new(medico, usuario, fecha_hora)
      RepositorioTurnos.new.save(turno)
    end
  end

  @response = Faraday.get("/turnos/#{medico.matricula}/disponibilidad")
  expect(@response.status).to eq(400)
end
