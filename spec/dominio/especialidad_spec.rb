require 'integration_helper'
require_relative '../../dominio/especialidad'

describe Especialidad do
  describe 'tiene_limite_disponible?' do
    let(:especialidad) { described_class.new('Cardiologia', 30, 2) }
    let(:medico) do
      instance_double('Medico',
                      especialidad: instance_double('Especialidad', nombre: 'Cardiologia'))
    end
    let(:turno_misma_especialidad) do
      instance_double('Turno', medico:)
    end

    it 'devuelve true cuando no hay turnos' do
      expect(especialidad.tiene_limite_disponible?([])).to be(true)
    end

    it 'devuelve true cuando hay turnos pero menos que el límite' do
      turnos = [turno_misma_especialidad]

      expect(especialidad.tiene_limite_disponible?(turnos)).to be(true)
    end

    it 'devuelve false cuando hay turnos que superan el límite' do
      turnos = [turno_misma_especialidad, turno_misma_especialidad, turno_misma_especialidad]

      expect(especialidad.tiene_limite_disponible?(turnos)).to be(false)
    end
  end
end
