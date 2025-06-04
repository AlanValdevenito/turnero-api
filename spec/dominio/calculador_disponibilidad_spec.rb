require 'spec_helper'
require 'date'
require_relative '../../dominio/calculador_disponibilidad'

describe 'CalculadorDeDisponibilidad' do
  describe '.turnos_para_dia' do
    let(:fecha) { Date.today + 1 }
    let(:duracion) { 30 }
    let(:inicio_jornada) { Time.local(fecha.year, fecha.month, fecha.day, 8, 0, 0) }
    let(:fecha_fin) { fecha + 3 }

    it 'devuelve la cantidad exacta de turnos si hay suficientes' do
      cantidad = 3
      turnos = CalculadorDeDisponibilidad.turnos_disponibles(duracion, [], cantidad, fecha, fecha_fin)

      expect(turnos.size).to eq(cantidad)
      expect(turnos).to all(be_a(Time))
    end

    it 'no devuelve turnos en fines de semana' do
      sabado = Date.parse('2025-06-07')
      domingo = Date.parse('2025-06-08')
      cantidad = 3

      turnos = CalculadorDeDisponibilidad.turnos_disponibles(duracion, [], cantidad, sabado, domingo)
      expect(turnos).to be_empty
    end

    it 'genera turnos cada duracion si no hay tiempos ocupados' do
      turnos = CalculadorDeDisponibilidad.turnos_para_dia(fecha, duracion, Set.new)

      expect(turnos).not_to be_empty
      expect(turnos.first).to be_a(Time)
      expect(turnos.size).to eq(20)
    end

    it 'no ofrece los turnos ocupados' do
      ocupado = Time.local(fecha.year, fecha.month, fecha.day, 9, 0, 0)
      tiempos_ocupados = Set.new([ocupado.to_i])

      turnos = CalculadorDeDisponibilidad.turnos_para_dia(fecha, duracion, tiempos_ocupados)

      horas = turnos.map { |t| [t.hour, t.min] }
      expect(horas).not_to include([9, 0])
    end

    it 'devuelve un turno si solo uno está disponible' do
      turnos_ocupados = (1...20).map do |i|
        (inicio_jornada + (i * duracion * 60)).to_i
      end.to_set

      turnos = CalculadorDeDisponibilidad.turnos_para_dia(fecha, duracion, turnos_ocupados)

      expect(turnos.first).to eq(inicio_jornada)
    end
  end
end
