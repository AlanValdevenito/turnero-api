require 'spec_helper'
Dir[File.join(__dir__, '../../dominio', '*.rb')].each { |file| require file }

describe GestorTurnos do
  let(:contexto) do
    {
      especialidad: Especialidad.new('Traumatologia', 10),
      usuario: Usuario.new('Juan@mail.com'),
      turno_mock: {
        fecha_hora: Time.now + 3600 # Un turno ficticio para pruebas
      }
    }.tap do |ctx|
      ctx[:medico] = Medico.new('Michael', 'Jordan', 1, ctx[:especialidad])
      turno = Turno.crear(
        Medico.new('Medico1', 'Apellido1', 'ABC123', ctx[:especialidad]),
        ctx[:usuario],
        '2025-06-05',
        '10:00'
      )
      ctx[:repositorio_turnos] = instance_double('RepositorioTurnos',
                                                 all: [],
                                                 buscar_por_usuario: [turno],
                                                 buscar_por_medico: [turno])
      ctx[:proveedor_dia] = instance_double('ProveedorDia', hoy: Date.parse('2025-06-16'))
      ctx[:proveedor_feriados] = instance_double('ProveedorFeriadosDummy', feriados: [{ dia: 16, mes: 6 }])
      ctx[:hora_base] = Time.new(2025, 6, 16, 10, 0, 0)
      ctx[:proveedor_hora] = instance_double('ProveedorHora', ahora: ctx[:hora_base], construir_hora: ctx[:hora_base])
      ctx[:gestor_turnos] = described_class.new(ctx[:repositorio_turnos], ctx[:proveedor_dia], ctx[:proveedor_feriados], ctx[:proveedor_hora])
    end
  end

  def stub_turnos_existentes(turnos)
    allow(contexto[:repositorio_turnos]).to receive(:obtener_turnos_existentes).and_return(turnos)
  end

  it 'deberia devolver turnos disponibles para el médico' do
    medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10))

    stub_turnos_existentes([])

    turnos_disponibles = contexto[:gestor_turnos].disponibilidad_de_medico(medico)
    expect(turnos_disponibles.size).to be <= TURNOS_DISPONIBLES
  end

  it 'deberia devolver turnos disponibles cuando algunos turnos ya están ocupados' do
    medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10))

    stub_turnos_existentes([contexto[:turno_mock]])
    turnos_disponibles = contexto[:gestor_turnos].disponibilidad_de_medico(medico)
    expect(turnos_disponibles).not_to include(contexto[:turno_mock][:fecha_hora])
  end

  it 'deberia devolver turnos disponibles de un usuario' do
    usuario = Usuario.new('Juan@mail.com')
    turnos = contexto[:gestor_turnos].turnos_paciente(usuario.email)
    expect(turnos.first.usuario.email).to eq(usuario.email)
  end

  it 'deberia devolver 0 turnos disponibles de un medico si no tiene turnos' do
    medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10))
    allow(contexto[:repositorio_turnos]).to receive(:buscar_por_medico).with(medico).and_return([])
    turnos = contexto[:gestor_turnos].turnos_medico(medico)
    expect(turnos.size).to eq(0)
  end

  it 'deberia devolver 1 turno disponible de un medico que tiene 1 turno' do
    especialidad = Especialidad.new('Traumatologia', 10)
    medico = Medico.new('Medico1', 'Apellido1', 'ABC123', especialidad)
    turnos = contexto[:gestor_turnos].turnos_medico(medico)
    expect(turnos.size).to eq(1)
  end

  def stub_buscar_turnos_por_medico(medico, turnos)
    allow(contexto[:repositorio_turnos]).to receive(:buscar_por_medico).with(medico).and_return(turnos)
  end

  def stub_save_turno_correcto(contexto)
    allow(contexto[:repositorio_turnos]).to receive(:save).with(instance_of(Turno)) do |turno|
      expect(turno.medico).to eq(contexto[:medico])
      expect(turno.usuario).to eq(contexto[:usuario])
      turno
    end
  end

  def stub_creacion_turno_correcta(contexto)
    stub_buscar_turnos_por_medico(contexto[:medico], [])
    stub_save_turno_correcto(contexto)
  end

  it 'deberia crear un turno correctamente' do
    stub_creacion_turno_correcta(contexto)

    turno = contexto[:gestor_turnos].crear_turno(contexto[:medico], contexto[:usuario], '2025-06-05', '10:00')
    expect(turno.fecha).to eq('2025-06-05')
  end

  context 'when hay más de 20 turnos para un usuario' do
    let(:usuario) { Usuario.new('pepe@mail.com') }
    let(:turnos) do
      (1..30).map do |i|
        Turno.new(
          Medico.new('Medico', 'Apellido', i, Especialidad.new('Traumatologia', 10)),
          usuario,
          DateTime.now + i
        )
      end
    end

    before(:each) do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).with(usuario).and_return(turnos)
    end

    it 'devuelve como máximo 20 turnos' do
      result = contexto[:gestor_turnos].turnos_paciente(usuario)
      expect(result.size).to be <= 20
    end

    it 'devuelve los turnos ordenados por fecha' do
      result = contexto[:gestor_turnos].turnos_paciente(usuario)
      fechas = result.map(&:fecha_hora)
      expect(fechas).to eq(fechas.sort)
    end

    it 'devuelve los 20 turnos más próximos' do
      result = contexto[:gestor_turnos].turnos_paciente(usuario)
      fechas = result.map(&:fecha_hora)
      expect(fechas).to eq(result.map(&:fecha_hora).sort.first(20))
    end

    def stub_turno_duplicado(contexto, _medico)
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_medico).with(instance_of(Medico)).and_return([])
      allow(contexto[:repositorio_turnos]).to receive(:save).with(instance_of(Turno)).and_raise(TurnoYaExisteException)
    end

    it 'no deberia guardar turnos duplicados' do
      medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10))
      stub_turno_duplicado(contexto, medico)
      expect do
        contexto[:gestor_turnos].crear_turno(medico, usuario, '2025-06-05', '10:00')
      end.to raise_error(TurnoYaExisteException)
    end
  end

  context 'when hay más de 20 turnos para un medico' do
    let(:especialidad) { Especialidad.new('Traumatologia', 10) }
    let(:medico) { Medico.new('Michael', 'Jordan', '1', especialidad) }
    let(:turnos) do
      (1..30).reverse_each.map do |i|
        Turno.new(
          medico,
          Usuario.new('usuario@prueba.com'),
          DateTime.now + i
        )
      end
    end

    before(:each) do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_medico).with(medico).and_return(turnos)
    end

    it 'devuelve los turnos de medicos ordenados por fecha' do
      result = contexto[:gestor_turnos].turnos_medico(medico)
      fechas = result.map(&:fecha_hora)
      expect(fechas).to eq(fechas.sort)
    end

    it 'devuelve solo 20 turnos de un medico' do
      result = contexto[:gestor_turnos].turnos_medico(medico)
      expect(result.size).to be <= 20
    end
  end

  describe '#proximos_turnos_paciente' do
    let(:especialidad) { instance_double('Especialidad', nombre: 'Traumatologia', duracion_de_turnos: 10) }
    let(:medico) { instance_double('Medico', nombre: 'Medico', apellido: 'Apellido', matricula: 1, especialidad:) }

    context 'when cuando hay turnos antes y después de la hora actual' do
      let(:ahora) { DateTime.parse('2025-06-16T15:00:00') }
      let(:turnos) do
        [
          instance_double('Turno', medico:, usuario: contexto[:usuario], fecha_hora: DateTime.parse('2025-06-16T14:00:00'), estado: 'Pendiente', id: 1),
          instance_double('Turno', medico:, usuario: contexto[:usuario], fecha_hora: DateTime.parse('2025-06-16T15:00:00'), estado: 'Pendiente', id: 2),
          instance_double('Turno', medico:, usuario: contexto[:usuario], fecha_hora: DateTime.parse('2025-06-16T16:00:00'), estado: 'Pendiente', id: 3)
        ]
      end

      before(:each) do
        allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).with(contexto[:usuario]).and_return(turnos)
        allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(ahora)
      end

      it 'devuelve solo los turnos desde la hora actual en adelante, ordenados por fecha y hora' do
        result = contexto[:gestor_turnos].proximos_turnos_paciente(contexto[:usuario])
        expect(result.size).to eq(2)
        expect(result.map(&:fecha_hora)).to eq([DateTime.parse('2025-06-16T15:00:00'), DateTime.parse('2025-06-16T16:00:00')])
        expect(result.map(&:id)).to eq([2, 3])
      end
    end

    context 'when cuando hay turnos cancelados' do
      let(:ahora) { DateTime.parse('2025-06-16T15:00:00') }
      let(:turnos) do
        [
          instance_double('Turno', medico:, usuario: contexto[:usuario], fecha_hora: DateTime.parse('2025-06-16T15:00:00'), estado: 'Pendiente', id: 1),
          instance_double('Turno', medico:, usuario: contexto[:usuario], fecha_hora: DateTime.parse('2025-06-16T16:00:00'), estado: 'Cancelado', id: 2),
          instance_double('Turno', medico:, usuario: contexto[:usuario], fecha_hora: DateTime.parse('2025-06-16T17:00:00'), estado: 'Pendiente', id: 3)
        ]
      end

      before(:each) do
        allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).with(contexto[:usuario]).and_return(turnos)
        allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(ahora)
      end

      it 'devuelve solo los turnos pendientes, no los cancelados' do
        result = contexto[:gestor_turnos].proximos_turnos_paciente(contexto[:usuario])
        expect(result.size).to eq(2)
        expect(result.map(&:estado)).to all(eq('Pendiente'))
        expect(result.map(&:id)).to eq([1, 3])
      end
    end

    context 'when cuando no hay próximos turnos' do
      let(:ahora) { DateTime.parse('2025-06-16T15:00:00') }
      let(:turnos) { [] }

      before(:each) do
        allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).with(contexto[:usuario]).and_return(turnos)
        allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(ahora)
      end

      it 'lanza NoHayProximosTurnosException si no hay próximos turnos' do
        expect do
          contexto[:gestor_turnos].proximos_turnos_paciente(contexto[:usuario])
        end.to raise_error(NoHayProximosTurnosException)
      end
    end
  end

  describe 'Editar estado turno' do
    let(:turnos) do
      {
        futuro: instance_double(
          'Turno',
          id: 2,
          estado: ESTADO_PENDIENTE,
          fecha_hora: DateTime.parse('2025-11-01T10:00:00')
        ),
        pasado: instance_double(
          'Turno',
          id: 3,
          estado: ESTADO_PENDIENTE,
          fecha_hora: DateTime.parse('2025-01-01T10:00:00')
        )
      }
    end

    before(:each) do
      allow(turnos[:futuro]).to receive(:estado=)
      allow(turnos[:pasado]).to receive(:estado=)
      allow(contexto[:repositorio_turnos]).to receive(:save).with(turnos[:futuro]).and_return(turnos[:futuro])
      allow(contexto[:repositorio_turnos]).to receive(:save).with(turnos[:pasado]).and_return(turnos[:pasado])
    end

    it 'permite cancelar un turno futuro' do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_id).with(2).and_return(turnos[:futuro])
      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(Time.new(2025, 6, 10, 9, 0, 0))
      expect(turnos[:futuro]).to receive(:estado=).with(ESTADO_CANCELADO)
      result = contexto[:gestor_turnos].modificar_estado_turno(2, ESTADO_CANCELADO)
      expect(result).to eq(turnos[:futuro])
    end

    it 'no permite cancelar un turno pasado' do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_id).with(3).and_return(turnos[:pasado])
      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(Time.new(2025, 6, 10, 9, 0, 0))
      expect { contexto[:gestor_turnos].modificar_estado_turno(3, ESTADO_CANCELADO) }.to raise_error(EstadoInvalidoException)
    end

    it 'permite marcar como asistido un turno pasado' do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_id).with(3).and_return(turnos[:pasado])
      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(Time.new(2025, 6, 10, 9, 0, 0))
      expect(turnos[:pasado]).to receive(:estado=).with(ESTADO_ASISTIDO)
      result = contexto[:gestor_turnos].modificar_estado_turno(3, ESTADO_ASISTIDO)
      expect(result).to eq(turnos[:pasado])
    end

    it 'no permite marcar como asistido un turno futuro' do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_id).with(2).and_return(turnos[:futuro])
      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(Time.new(2025, 1, 1, 9, 0, 0))
      expect { contexto[:gestor_turnos].modificar_estado_turno(2, ESTADO_ASISTIDO) }.to raise_error(EstadoInvalidoException)
    end
  end
end
