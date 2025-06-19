require 'integration_helper'
require_relative '../../dominio/especialidad'

describe Especialidad do
  describe 'tiene_limite_disponible?' do
    let(:especialidad) { described_class.new('Cardiologia', 30, 2) }
    let(:medico) do
      instance_double('Medico',
                      especialidad: instance_double('Especialidad', nombre: 'Cardiologia'))
    end

    def crear_turno(estado)
      instance_double('Turno', medico:, estado:)
    end

    def crear_turnos(*estados)
      estados.map { |estado| crear_turno(estado) }
    end

    it 'devuelve true cuando no hay turnos' do
      expect(especialidad.tiene_limite_disponible?([])).to be(true)
    end

    it 'devuelve true cuando hay turnos pero menos que el límite' do
      turnos = crear_turnos('Pendiente')
      expect(especialidad.tiene_limite_disponible?(turnos)).to be(true)
    end

    it 'devuelve false cuando hay turnos que superan el límite' do
      turnos = crear_turnos('Pendiente', 'Pendiente', 'Pendiente')
      expect(especialidad.tiene_limite_disponible?(turnos)).to be(false)
    end

    it 'devuelve true cuando hay turnos cancelados que no cuentan para el límite' do
      turnos = crear_turnos('Cancelado', 'Cancelado', 'Cancelado', 'Pendiente')
      expect(especialidad.tiene_limite_disponible?(turnos)).to be(true)
    end

    it 'devuelve true cuando hay turnos asistidos que no cuentan para el límite' do
      turnos = crear_turnos('Asistido', 'Asistido', 'Asistido', 'Pendiente')
      expect(especialidad.tiene_limite_disponible?(turnos)).to be(true)
    end

    it 'devuelve true cuando hay turnos ausentes que no cuentan para el límite' do
      turnos = crear_turnos('Ausente', 'Ausente', 'Ausente', 'Pendiente')
      expect(especialidad.tiene_limite_disponible?(turnos)).to be(true)
    end

    it 'devuelve false cuando hay suficientes turnos pendientes para superar el límite' do
      turnos = crear_turnos('Pendiente', 'Cancelado', 'Pendiente', 'Asistido')
      expect(especialidad.tiene_limite_disponible?(turnos)).to be(false)
    end
  end
end
