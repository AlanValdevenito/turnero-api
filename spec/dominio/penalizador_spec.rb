require 'spec_helper'

describe Penalizador do
  let(:usuario) { instance_double('Usuario', penalizable: true) }
  let(:proveedor_hora) { instance_double('ProveedorHora') }
  let(:gestor_usuarios) { instance_double('GestorUsuarios') }
  let(:penalizador) { described_class.new(proveedor_hora, gestor_usuarios) }

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

  describe '#penalizar_si_corresponde' do
    let(:hora_base) { Time.now }

    before(:each) do
      allow(proveedor_hora).to receive(:ahora).and_return(hora_base)
      allow(gestor_usuarios).to receive(:actualizar)
      allow(usuario).to receive(:ultima_penalizacion).and_return(nil)
      allow(usuario).to receive(:ultima_penalizacion=)
      allow(usuario).to receive(:penalizable=)
    end

    def set_usuario_estado(penalizable:, ultima_penalizacion:)
      allow(usuario).to receive(:penalizable).and_return(penalizable)
      allow(usuario).to receive(:ultima_penalizacion).and_return(ultima_penalizacion)
    end

    it 'no penaliza ni actualiza si el usuario no es penalizable' do
      allow(usuario).to receive(:penalizable).and_return(false)
      expect(gestor_usuarios).not_to receive(:actualizar)
      expect do
        penalizador.penalizar_si_corresponde(usuario, REPUTACION_MINIMA - 1)
      end.not_to raise_error
    end

    it 'penaliza al usuario si la reputación es baja' do
      set_usuario_estado(penalizable: true, ultima_penalizacion: nil)
      expect(usuario).to receive(:ultima_penalizacion=).with(hora_base.to_datetime)
      expect(usuario).to receive(:penalizable=).with(false)
      expect { penalizador.penalizar_si_corresponde(usuario, REPUTACION_MINIMA - 1) }.to raise_error(PenalizacionPorReputacionException)
    end

    it 'actualiza el usuario penalizado si la reputación es baja' do
      set_usuario_estado(penalizable: true, ultima_penalizacion: nil)
      expect(gestor_usuarios).to receive(:actualizar).with(usuario)
      expect do
        penalizador.penalizar_si_corresponde(usuario, REPUTACION_MINIMA - 1)
      end.to raise_error(PenalizacionPorReputacionException)
    end

    it 'no penaliza ni actualiza si la reputación es suficiente' do
      set_usuario_estado(penalizable: true, ultima_penalizacion: nil)
      expect(gestor_usuarios).not_to receive(:actualizar)
      expect do
        penalizador.penalizar_si_corresponde(usuario, REPUTACION_MINIMA + 1)
      end.not_to raise_error
    end
  end

  describe '#actualizar_flag_penalizable' do
    it 'actualiza el flag penalizable a true si el estado es ausente' do
      allow(usuario).to receive(:penalizable=)
      expect(gestor_usuarios).to receive(:actualizar).with(usuario)
      penalizador.actualizar_flag_penalizable(usuario, ESTADO_AUSENTE)
      expect(usuario.penalizable).to be true
    end

    it 'no actualiza el flag penalizable si el estado no es ausente' do
      allow(usuario).to receive(:penalizable=)
      expect(gestor_usuarios).not_to receive(:actualizar)
      penalizador.actualizar_flag_penalizable(usuario, ESTADO_PENDIENTE)
    end
  end
end
