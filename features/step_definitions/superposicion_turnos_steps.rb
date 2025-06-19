Dado('la especialidad {string} dada de alta cuya duracion de turnos es {int} minutos') do |nombre, duracion_de_turnos|
  request_body = { nombre:, duracion_de_turnos:, limite_turnos_por_usuario: 100 }.to_json
  @response = api_post('/especialidades', request_body)
  expect(@response.status).to eq(200)
end

Dado('que para la fecha {string} y hora {string} reserve un turno con el médico con matrícula {string}') do |fecha, hora, matricula|
  request_body = { matricula:, fecha:, hora:, email: @email }.to_json
  @response = api_post('/turnos', request_body)
  expect(@response.status).to eq(201)
end

Cuando('quiero reservar otro turno para la fecha {string} y hora {string} con el médico con matrícula {string}') do |fecha, hora, matricula|
  request_body = { matricula:, fecha:, hora:, email: @email }.to_json
  @response = api_post('/turnos', request_body)
end

Entonces('se muestra un exito {int}') do |codigo|
  expect(@response.status).to eq(codigo)
end
