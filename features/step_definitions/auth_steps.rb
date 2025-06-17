Cuando('envío una request a la API sin incluir una API KEY en el header') do
  @response = Faraday.get('/version')
end

Entonces('la API responde con un mensaje de error de autenticación') do
  expect(@response.body).to match(/error/i)
end
