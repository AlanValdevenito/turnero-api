require 'spec_helper'

describe Penalizador do
  let(:usuario) { instance_double('Usuario') }
  let(:proveedor_hora) { instance_double('ProveedorHora') }
  let(:penalizador) { described_class.new(proveedor_hora) }

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
