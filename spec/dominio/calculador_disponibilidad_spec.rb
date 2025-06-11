require 'spec_helper'
require 'date'
require_relative '../../dominio/adapters/proveedor_dia'
require_relative '../../dominio/adapters/proveedor_hora'
require_relative '../../dominio/calculador_disponibilidad'

describe 'CalculadorDeDisponibilidad' do
  before(:each) do
    stub_const('CANTIDAD_TURNOS', 3)
  end

  describe '.turnos_para_dia' do
    let(:fecha) { Date.parse('2025-06-12') }
    let(:duracion) { 30 }
    let(:inicio_jornada) { DateTime.parse("#{fecha}T08:00:00") }
    let(:fecha_fin) { fecha + 3 }
    let(:calculador) { CalculadorDeDisponibilidad.new(ProveedorDia.new, ProveedorHora.new, ProveedorFeriados.new) }

    def stub_feriados_api
      stub_request(:get, 'https://nolaborables.com.ar/api/v2/feriados/2025')
        .to_return(status: 200, body: '[{ "dia": 16, "mes": 6 }]', headers: {})
    end

    it 'devuelve la cantidad exacta de turnos si hay suficientes' do
      cantidad = 3
      stub_feriados_api
      turnos = calculador.turnos_disponibles(duracion, [], cantidad, fecha, fecha_fin)

      expect(turnos.size).to eq(cantidad)
      expect(turnos).to all(be_a(DateTime))
    end

    it 'no devuelve turnos en fines de semana' do
      stub_feriados_api
      sabado = Date.parse('2025-06-07')
      domingo = Date.parse('2025-06-08')

      turnos = calculador.turnos_disponibles(duracion, [], CANTIDAD_TURNOS, sabado, domingo)
      expect(turnos).to be_empty
    end

    it 'genera turnos cada duracion si no hay tiempos ocupados' do
      turnos = calculador.turnos_para_dia(fecha, duracion, Set.new)

      expect(turnos).not_to be_empty
      expect(turnos.first).to be_a(DateTime)
      expect(turnos.size).to eq(20)
    end

    it 'no ofrece los turnos ocupados' do
      ocupado = DateTime.parse("#{fecha}T09:00:00")
      tiempos_ocupados = Set.new([ocupado.to_time.to_i])

      turnos = calculador.turnos_para_dia(fecha, duracion, tiempos_ocupados)

      horas = turnos.map { |t| [t.hour, t.min] }
      expect(horas).not_to include([9, 0])
    end

    it 'devuelve un turno si solo uno está disponible' do
      turnos_ocupados = (1...20).map do |i|
        (inicio_jornada + Rational(i * duracion, 1440))
      end.to_set

      turnos = calculador.turnos_para_dia(fecha, duracion, turnos_ocupados.map(&:to_time).map(&:to_i).to_set)

      expect(turnos.first).to eq(inicio_jornada)
    end

    it 'no devuelve turnos en feriados o no laborables' do
      stub_feriados_api
      feriado = Date.parse('2025-06-16')
      cantidad = 3
      turnos = calculador.turnos_disponibles(duracion, [], cantidad, feriado, feriado + 1)
      expect(turnos).to be_empty
    end
  end
end
