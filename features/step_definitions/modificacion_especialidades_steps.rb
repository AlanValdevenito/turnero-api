Dado('existe la especialidad con nombre {string}, con límite de {int} turnos por usuario y con duracion por cada turno de {int} minutos') do |especialidad, limite, duracion|
  request_body = { nombre: especialidad, duracion_de_turnos: duracion, limite_turnos_por_usuario: limite }
  @response = api_post('/especialidades', request_body.to_json)
  expect(@response.status).to eq(200)
end

Dado('que actualizo la especialidad {string} con un nuevo nombre {string} y con un nuevo limite de {int} turnos por usuarios') do |especialidad, nueva_especialidad, nuevo_limite|
  request_body = { nombre: nueva_especialidad, limite_turnos_por_usuario: nuevo_limite }
  @response = api_put("/especialidades/#{especialidad}", request_body.to_json)
end

Entonces('la respuesta es {int}') do |codigo|
  expect(@response.status).to eq(codigo)
end

Entonces('se muestra la informacion actualizada donde el nombre es {string}') do |nombre_actualizado|
  especialidad = JSON.parse(@response.body)
  expect(especialidad['nombre']).to eq(nombre_actualizado)
end

Entonces('el limite de turnos por usuarios es {int}') do |limite_actualizado|
  especialidad = JSON.parse(@response.body)
  expect(especialidad['limite_turnos_por_usuario']).to eq(limite_actualizado)
end

Entonces('la duracion por cada turno es {int} minutos') do |duracion_actualizada|
  especialidad = JSON.parse(@response.body)
  expect(especialidad['duracion_de_turnos']).to eq(duracion_actualizada)
end

Dado('que actualizo la especialidad {string} con un nuevo nombre {string} y con un nuevo limite de {string} turnos por usuarios') do |especialidad, nueva_especialidad, nuevo_limite|
  request_body = { nombre: nueva_especialidad, limite_turnos_por_usuario: nuevo_limite }
  @response = api_put("/especialidades/#{especialidad}", request_body.to_json)
end
