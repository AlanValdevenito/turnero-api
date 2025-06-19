require 'spec_helper'
require_relative '../../dominio/calculador_reputacion'

describe CalculadorReputacion do
  let(:usuario) { instance_double('Usuario') }
  let(:repositorio_turnos) { instance_double('RepositorioTurnos') }
  let(:calculador) { described_class.new(repositorio_turnos) }

  def turno_con_estado(estado)
    instance_double('Turno', estado:)
  end

  it 'calcula 100 si no hay turnos no pendientes' do
    allow(repositorio_turnos).to receive(:buscar_por_usuario).with(usuario).and_return([
                                                                                         turno_con_estado('Pendiente'),
                                                                                         turno_con_estado('Pendiente')
                                                                                       ])
    expect(calculador.calcular_reputacion(usuario)).to eq(100)
  end

  it 'calcula correctamente la reputacion' do
    allow(repositorio_turnos).to receive(:buscar_por_usuario).with(usuario).and_return([turno_con_estado('Asistido'), turno_con_estado('Cancelado'),
                                                                                        turno_con_estado('Ausente'),
                                                                                        turno_con_estado('Pendiente')])
    # (1 asistido + 1 cancelado) / (4 totales - 1 pendiente) = 2/3 = 66.67 => 67
    expect(calculador.calcular_reputacion(usuario)).to eq(67)
  end

  it 'calcula 0 si todos los turnos son ausentes' do
    allow(repositorio_turnos).to receive(:buscar_por_usuario).with(usuario).and_return([
                                                                                         turno_con_estado('Ausente'),
                                                                                         turno_con_estado('Ausente')
                                                                                       ])
    expect(calculador.calcular_reputacion(usuario)).to eq(0)
  end
end
