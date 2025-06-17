require 'rspec/mocks'

World(RSpec::Mocks::ExampleMethods)

Dado('el usuario pide los turnos disponibles del médico con matrícula {string} siendo {string}') do |matricula, fecha|
  allow_any_instance_of(ProveedorFecha).to receive(:hoy).and_return(Date.parse('2025-06-16'))
  @fecha = fecha
  @response = api_get("/turnos/#{matricula}/disponibilidad")
  expect(@response.status).to eq(200)
end

Entonces('se muestran los próximos {int} turnos disponibles del médico dentro de los próximos {int} meses') do |cant_turnos, _cant_meses|
  @json_response = JSON.parse(@response.body)
  expect(@json_response.size).to eq(cant_turnos)
end

Entonces('no aparecen turnos disponibles para el dia de la consulta') do
  fechas = @json_response.map { |registro| registro['fecha'] }
  expect(fechas).not_to include(@fecha)
end
