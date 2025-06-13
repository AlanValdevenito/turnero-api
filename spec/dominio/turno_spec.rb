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
    fecha_hora = DateTime.parse((ProveedorHora.new.ahora + 48 * 60 * 60).to_s)
    turno = described_class.new(medico, usuario, fecha_hora)
    expect(turno.proximas_24hs?(ProveedorHora.new.ahora)).to eq(false)
  end

  it 'devuelve true si ocurre en las proximas 24hs' do
    medico = Medico.new('Juan', 'Perez', 'ABC123', Especialidad.new('Traumatologia', 10))
    usuario = Usuario.new('usuario@prueba.com')
    fecha_hora = DateTime.parse((ProveedorHora.new.ahora + 10 * 60 * 60).to_s)
    turno = described_class.new(medico, usuario, fecha_hora)
    expect(turno.proximas_24hs?(ProveedorHora.new.ahora)).to eq(true)
  end
end
