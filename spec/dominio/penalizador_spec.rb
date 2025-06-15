require 'spec_helper'

describe Penalizador do
  let(:usuario) { instance_double('Usuario') }
  let(:repositorio_turnos) { instance_double('RepositorioTurnos') }
  let(:proveedor_hora) { instance_double('ProveedorHora') }
  let(:penalizador) { described_class.new(repositorio_turnos, proveedor_hora) }

  def turno_con_estado(estado)
    instance_double('Turno', estado:)
  end

  it 'calcula 100 si no hay turnos no pendientes' do
    allow(repositorio_turnos).to receive(:buscar_por_usuario).with(usuario).and_return([
                                                                                         turno_con_estado('Pendiente'),
                                                                                         turno_con_estado('Pendiente')
                                                                                       ])
    expect(penalizador.calcular_reputacion(usuario)).to eq(100)
  end

  it 'calcula correctamente la reputacion' do
    allow(repositorio_turnos).to receive(:buscar_por_usuario).with(usuario).and_return([turno_con_estado('Asistido'), turno_con_estado('Cancelado'),
                                                                                        turno_con_estado('Ausente'),
                                                                                        turno_con_estado('Pendiente')])
    # (1 asistido + 1 cancelado) / (4 totales - 1 pendiente) = 2/3 = 66.67 => 67
    expect(penalizador.calcular_reputacion(usuario)).to eq(67)
  end

  it 'calcula 0 si todos los turnos son ausentes' do
    allow(repositorio_turnos).to receive(:buscar_por_usuario).with(usuario).and_return([
                                                                                         turno_con_estado('Ausente'),
                                                                                         turno_con_estado('Ausente')
                                                                                       ])
    expect(penalizador.calcular_reputacion(usuario)).to eq(0)
  end

  describe '#chequeo_penalizacion_vigente' do
    let(:hora_base) { Time.now }

    it 'no lanza excepción si el usuario no tiene penalización' do
      allow(usuario).to receive(:ultima_penalizacion).and_return(nil)
      allow(proveedor_hora).to receive(:ahora).and_return(hora_base)
      expect { penalizador.chequeo_penalizacion_vigente(usuario) }.not_to raise_error
    end

    it 'lanza excepción si la penalización está vigente' do
      penalizacion_time = hora_base - 60 # penalización hace 1 minuto
      allow(usuario).to receive(:ultima_penalizacion).and_return(penalizacion_time)
      allow(proveedor_hora).to receive(:ahora).and_return(hora_base)
      stub_const('DURACION_PENALIDAD', 3) # 3 minutos

      expect { penalizador.chequeo_penalizacion_vigente(usuario) }.to raise_error(PenalizacionPorReputacionException)
    end

    it 'no lanza excepción si la penalización ya expiró' do
      penalizacion_time = hora_base - 5 * 60 # penalización hace 5 minutos
      allow(usuario).to receive(:ultima_penalizacion).and_return(penalizacion_time)
      allow(proveedor_hora).to receive(:ahora).and_return(hora_base)
      stub_const('DURACION_PENALIDAD', 3) # 3 minutos

      expect { penalizador.chequeo_penalizacion_vigente(usuario) }.not_to raise_error
    end
  end
end
