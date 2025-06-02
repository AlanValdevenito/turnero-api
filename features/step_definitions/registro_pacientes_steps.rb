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
