require 'rspec'
require 'time'
require_relative '../../dominio/adaptador_zona_horaria'

RSpec.describe AdaptadorZonaHoraria do
  let(:proveedor_hora) do
    instance_double(
      'ProveedorHora',
      huso_horario: '-03:00',
      construir_hora_desde_local: Time.utc(2023, 3, 3, 13, 20),
      cambiar_a_huso_horario_local: Time.new(2023, 3, 3, 10, 20, 0, '-03:00')
    )
  end

  let(:adaptador) { described_class.new(proveedor_hora) }

  describe '#parsear_a_utc' do
    it 'convierte fecha y hora local a dos strings en UTC' do
      expect(adaptador.parsear_a_utc('2023-03-03', '10:20')).to eq(['2023-03-03', '13:20'])
    end
  end

  describe '#adaptar_zona_horaria' do
    let(:turno) do
      instance_double(
        'Turno',
        id: 1,
        medico: 'Dr. House',
        usuario: 'Paciente',
        estado: 'pendiente',
        fecha_hora: Time.utc(2023, 3, 3, 13, 20)
      )
    end

    before(:each) do
      allow(turno).to receive(:cambiar_fecha_hora) do |nueva_fecha_hora|
        allow(turno).to receive(:fecha_hora).and_return(nueva_fecha_hora)
      end
    end

    it 'modifica la fecha_hora del mismo turno' do
      result = adaptador.adaptar_zona_horaria(turno)
      expect(result).to eq(turno)
      expect(turno.fecha_hora).to eq(Time.new(2023, 3, 3, 10, 20, 0, '-03:00').to_datetime)
    end
  end

  describe '#adaptar_zona_horaria_turnos' do
    let(:turno1) do
      instance_double('Turno', id: 1, medico: 'A', usuario: 'U', estado: 'ok', fecha_hora: Time.utc(2023, 3, 3, 13, 20))
    end
    let(:turno2) do
      instance_double('Turno', id: 2, medico: 'B', usuario: 'V', estado: 'ok', fecha_hora: Time.utc(2023, 3, 4, 13, 20))
    end

    before(:each) do
      [turno1, turno2].each do |t|
        allow(t).to receive(:cambiar_fecha_hora) do |nueva_fecha_hora|
          allow(t).to receive(:fecha_hora).and_return(nueva_fecha_hora)
        end
      end
      allow(proveedor_hora).to receive(:cambiar_a_huso_horario_local).and_return(
        Time.new(2023, 3, 3, 10, 20, 0, '-03:00'),
        Time.new(2023, 3, 4, 10, 20, 0, '-03:00')
      )
    end

    def expect_mismos_turnos(turnos)
      expect(turnos.size).to eq(2)
      expect(turnos.first).to eq(turno1)
      expect(turnos.last).to eq(turno2)
    end

    it 'devuelve los mismos turnos pero con la fecha_hora adaptada' do
      turnos = [turno1, turno2]
      result = adaptador.adaptar_zona_horaria_turnos(turnos)
      expect_mismos_turnos(result)
      expect(result.first.fecha_hora).to eq(Time.new(2023, 3, 3, 10, 20, 0, '-03:00').to_datetime)
      expect(result.last.fecha_hora).to eq(Time.new(2023, 3, 4, 10, 20, 0, '-03:00').to_datetime)
    end
  end

  describe '#adaptar_zona_horarios' do
    it 'convierte un array de horarios UTC a horarios locales' do
      horarios_utc = [Time.utc(2023, 3, 3, 13, 20)]
      expect(adaptador.adaptar_zona_horarios(horarios_utc)).to eq([Time.new(2023, 3, 3, 10, 20, 0, '-03:00')])
    end
  end
end
