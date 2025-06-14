require 'rspec'
require 'time'
require_relative '../../dominio/parser_horarios_turnero'

RSpec.describe ParserHorariosTurnero do
  let(:proveedor_hora) do
    instance_double(
      'ProveedorHora',
      huso_horario: '-03:00',
      construir_hora_desde_local: Time.utc(2023, 3, 3, 13, 20),
      cambiar_a_huso_horario_local: Time.new(2023, 3, 3, 10, 20, 0, '-03:00')
    )
  end

  let(:parser) { described_class.new(proveedor_hora) }

  describe '#parsear_a_utc' do
    it 'convierte fecha y hora local a dos strings en UTC' do
      expect(parser.parsear_a_utc('2023-03-03', '10:20')).to eq(['2023-03-03', '13:20'])
    end
  end

  describe '#parsear_turno' do
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

    it 'devuelve un TurnoParseado con los datos correctos' do
      turno_parseado = parser.parsear_turno(turno)
      expect(turno_parseado).to have_attributes(id: 1, medico: 'Dr. House', usuario: 'Paciente', estado: 'pendiente',
                                                fecha_hora: Time.new(2023, 3, 3, 10, 20, 0, '-03:00'))
    end
  end

  describe '#parsear_turnos' do
    let(:turno1) do
      instance_double('Turno', id: 1, medico: 'A', usuario: 'U', estado: 'ok', fecha_hora: Time.utc(2023, 3, 3, 13, 20))
    end
    let(:turno2) do
      instance_double('Turno', id: 2, medico: 'B', usuario: 'V', estado: 'ok', fecha_hora: Time.utc(2023, 3, 4, 13, 20))
    end

    before(:each) do
      allow(proveedor_hora).to receive(:cambiar_a_huso_horario_local).and_return(
        Time.new(2023, 3, 3, 10, 20, 0, '-03:00'),
        Time.new(2023, 3, 4, 10, 20, 0, '-03:00')
      )
    end

    it 'devuelve un array de TurnoParseado' do
      result = parser.parsear_turnos([turno1, turno2])
      expect(result.size).to eq(2)
      expect(result.first).to be_a(TurnoParseado)
      expect(result.last).to be_a(TurnoParseado)
    end
  end

  describe '#parsear_horarios' do
    it 'convierte un array de horarios UTC a horarios locales' do
      horarios_utc = [Time.utc(2023, 3, 3, 13, 20)]
      expect(parser.parsear_horarios(horarios_utc)).to eq([Time.new(2023, 3, 3, 10, 20, 0, '-03:00')])
    end
  end
end
