Cuando('envío una request a la API sin incluir una API KEY en el header') do
  @response = Faraday.get('/test-api-key')
end

Entonces('la API responde con un mensaje de error de autenticación de key faltante') do
  expect(@response.body).to include('Error de autenticación: falta la API Key')
end

Cuando('envío una request a la API incluyendo una API KEY inválida en el header') do
  @response = Faraday.get('/test-api-key', nil, { 'X-API-KEY' => 'INVALIDA' })
end

Entonces('la API responde con un mensaje de error de autenticación de key invalida') do
  expect(@response.body).to include('Error de autenticación: API key inválida')
end
