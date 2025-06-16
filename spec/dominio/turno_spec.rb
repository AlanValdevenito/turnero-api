require 'spec_helper'
require_relative '../../dominio/turno'

describe Turno do
  it 'deberia tener estado pendiente si el turno es nuevo' do
    medico = Medico.new('Juan', 'Perez', 'ABC123', Especialidad.new('Traumatologia', 10, 5))
    usuario = Usuario.new('Alan@prueba.com')
    fecha_hora = DateTime.parse('2025-06-05T10:00:00')

    turno = described_class.new(medico, usuario, fecha_hora)
    expect(turno.estado).to eq('Pendiente')
  end

  it 'devuelve false si no ocurre en las proximas 24hs' do
    medico = Medico.new('Juan', 'Perez', 'ABC123', Especialidad.new('Traumatologia', 10, 5))
    usuario = Usuario.new('usuario@prueba.com')
    fecha_hora = DateTime.parse((ProveedorHora.new.ahora + 48 * 60 * 60).to_s)
    turno = described_class.new(medico, usuario, fecha_hora)
    expect(turno.proximas_24hs?(ProveedorHora.new.ahora)).to eq(false)
  end

  it 'devuelve true si ocurre en las proximas 24hs' do
    medico = Medico.new('Juan', 'Perez', 'ABC123', Especialidad.new('Traumatologia', 10, 5))
    usuario = Usuario.new('usuario@prueba.com')
    fecha_hora = DateTime.parse((ProveedorHora.new.ahora + 10 * 60 * 60).to_s)
    turno = described_class.new(medico, usuario, fecha_hora)
    expect(turno.proximas_24hs?(ProveedorHora.new.ahora)).to eq(true)
  end

  def expect_fecha_y_hora(turno, fecha_esperada, hora_esperada)
    expect(turno.fecha).to eq(fecha_esperada)
    expect(turno.hora).to eq(hora_esperada)
  end

  it 'puede cambiar la fecha del turno' do
    medico = Medico.new('Juan', 'Perez', 'ABC123', Especialidad.new('Traumatologia', 10, 5))
    usuario = Usuario.new('usuario@prueba.com')
    turno = described_class.new(medico, usuario, DateTime.parse('2025-06-05T10:00:00'))

    turno.cambiar_fecha('2025-07-01')
    expect_fecha_y_hora(turno, '2025-07-01', '10:00')
  end

  it 'puede cambiar la hora del turno' do
    medico = Medico.new('Juan', 'Perez', 'ABC123', Especialidad.new('Traumatologia', 10, 5))
    usuario = Usuario.new('usuario@prueba.com')
    turno = described_class.new(medico, usuario, DateTime.parse('2025-06-05T10:00:00'))

    turno.cambiar_hora('15:30')
    expect_fecha_y_hora(turno, '2025-06-05', '15:30')
  end

  it 'puede cambiar la fecha y hora del turno con un DateTime' do
    medico = Medico.new('Juan', 'Perez', 'ABC123', Especialidad.new('Traumatologia', 10, 5))
    usuario = Usuario.new('usuario@prueba.com')
    turno = described_class.new(medico, usuario, DateTime.parse('2025-06-05T10:00:00'))

    turno.cambiar_fecha_hora(DateTime.parse('2025-08-10T18:45:00'))
    expect_fecha_y_hora(turno, '2025-08-10', '18:45')
  end
end
