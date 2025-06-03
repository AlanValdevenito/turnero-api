Dado('el paciente no está registrado y el email {string} no está en uso') do |email|
  response = Faraday.get("/usuarios/#{email}")
  expect(response.status).to eq(404)
end

Cuando('se quiere registrar con el mail {string}') do |email|
  request_body = { email: }.to_json
  @response = Faraday.post('/usuarios', request_body, { 'Content-Type' => 'application/json' })
end

Entonces('se registra exitosamente con el mensaje {string}') do |mensaje|
  expect(@response.status).to eq(201)
  expect(@response.body).to include(mensaje)
end

Dado('el email {string} ya está en uso') do |email|
  request_body = { email: }.to_json
  Faraday.post('/usuarios', request_body, { 'Content-Type' => 'application/json' })
end

Cuando('otro paciente se quiere registrar con el mail {string}') do |mail|
  request_body = { email: mail }.to_json
  @response = Faraday.post('/usuarios', request_body, { 'Content-Type' => 'application/json' })
end

Entonces('se muestra un error con el mensaje {string}') do |mensaje|
  expect(@response.status).to eq(400)
  expect(@response.body).to include(mensaje)
end

Dado('el paciente ya está registrado con un id de telegram {int}') do |telegram_id|
  request_body = { email: "telegram#{telegram_id}@ejemplo.com", telegram_id: }.to_json
  Faraday.post('/usuarios', request_body, { 'Content-Type' => 'application/json' })
end

Cuando('se quiere registrar con el mail {string} y el id de telegram {int}') do |string, int|
  request_body = { email: string, telegram_id: int }.to_json
  @response = Faraday.post('/usuarios', request_body, { 'Content-Type' => 'application/json' })
end

Dado('el paciente no está registrado') do
  # nada
end

Cuando('se quiere registrar sin especificar el mail') do
  request_body = { telegram_id: 123_456_789 }.to_json
  @response = Faraday.post('/usuarios', request_body, { 'Content-Type' => 'application/json' })
end
