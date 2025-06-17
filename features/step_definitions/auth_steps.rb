Cuando('envío una request a la API sin incluir una API KEY en el header') do
  @response = Faraday.get('/test-api-key')
end

Entonces('la API responde con un mensaje de error de autenticación') do
  expect(@response.body).to include('Error de autenticación: falta la API Key')
end
