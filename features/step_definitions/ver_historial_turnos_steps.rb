Dado('que nunca reserve un turno') do
  # Nada
end

Cuando('quiero ver mi historial de turnos') do
  @response = Faraday.get("/turnos/pacientes/historial/#{@telegram_id}")
  @turnos = JSON.parse(@response.body)
end

Entonces('se muestra el mensaje {string}') do |mensaje|
  expect(@response.status).to eq(400)
  expect(@response.body).to include(mensaje)
end
