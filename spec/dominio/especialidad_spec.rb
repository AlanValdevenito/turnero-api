require 'integration_helper'
require_relative '../../dominio/especialidad'

describe Especialidad do
  describe 'tiene_limite_disponible?' do
    let(:especialidad) { described_class.new('Cardiologia', 30, 2) }
    let(:medico) do
      instance_double('Medico',
                      especialidad: instance_double('Especialidad', nombre: 'Cardiologia'))
    end
    let(:turno_pendiente) do
      instance_double('Turno', medico:, estado: 'Pendiente')
    end
    let(:turno_cancelado) do
      instance_double('Turno', medico:, estado: 'Cancelado')
    end
    let(:turno_asistido) do
      instance_double('Turno', medico:, estado: 'Asistido')
    end
    let(:turno_ausente) do
      instance_double('Turno', medico:, estado: 'Ausente')
    end

    it 'devuelve true cuando no hay turnos' do
      expect(especialidad.tiene_limite_disponible?([])).to be(true)
    end

    it 'devuelve true cuando hay turnos pero menos que el límite' do
      turnos = [turno_pendiente]

      expect(especialidad.tiene_limite_disponible?(turnos)).to be(true)
    end

    it 'devuelve false cuando hay turnos que superan el límite' do
      turnos = [turno_pendiente, turno_pendiente, turno_pendiente]

      expect(especialidad.tiene_limite_disponible?(turnos)).to be(false)
    end

    it 'devuelve true cuando hay turnos cancelados que no cuentan para el límite' do
      turnos = [turno_cancelado, turno_cancelado, turno_cancelado, turno_pendiente]

      expect(especialidad.tiene_limite_disponible?(turnos)).to be(true)
    end

    it 'devuelve true cuando hay turnos asistidos que no cuentan para el límite' do
      turnos = [turno_asistido, turno_asistido, turno_asistido, turno_pendiente]

      expect(especialidad.tiene_limite_disponible?(turnos)).to be(true)
    end

    it 'devuelve true cuando hay turnos ausentes que no cuentan para el límite' do
      turnos = [turno_ausente, turno_ausente, turno_ausente, turno_pendiente]

      expect(especialidad.tiene_limite_disponible?(turnos)).to be(true)
    end

    it 'devuelve false cuando hay suficientes turnos pendientes para superar el límite' do
      turnos = [turno_pendiente, turno_cancelado, turno_pendiente, turno_asistido]

      expect(especialidad.tiene_limite_disponible?(turnos)).to be(false)
    end
  end
end
