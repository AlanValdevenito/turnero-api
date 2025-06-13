require 'spec_helper'
require_relative '../../dominio/turno'

describe Turno do
  it 'deberia tener estado pendiente si el turno es nuevo' do
    medico = Medico.new('Juan', 'Perez', 'ABC123', Especialidad.new('Traumatologia', 10))
    usuario = Usuario.new('Alan@prueba.com')
    fecha_hora = DateTime.parse('2025-06-05T10:00:00')

    turno = described_class.new(medico, usuario, fecha_hora)
    expect(turno.estado).to eq('Pendiente')
  end

  it 'devuelve false si no ocurre en las proximas 24hs' do
    medico = Medico.new('Juan', 'Perez', 'ABC123', Especialidad.new('Traumatologia', 10))
    usuario = Usuario.new('usuario@prueba.com')
    fecha_hora = DateTime.parse("#{ProveedorDia.new.hoy + 2} 00:00")
    turno = described_class.new(medico, usuario, fecha_hora)
    expect(turno.proximas_24hs).to eq(false)
  end
end
