require 'spec_helper'
Dir[File.join(__dir__, '../../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../dominio/excepciones', '*.rb')].each { |file| require file }

describe GestorTurnos do
  before(:each) do
    stub_const('MAXIMA_CANTIDAD_TURNOS_HISTORIAL_VISIBLES', 15)
  end

  let(:contexto) do
    {
      especialidad: Especialidad.new('Traumatologia', 10),
      usuario: Usuario.new('Juan@mail.com')
    }.tap do |ctx|
      ctx[:medico] = Medico.new('Michael', 'Jordan', 1, ctx[:especialidad])

      # ProveedorHora mock
      ctx[:hora_base] = Time.utc(2025, 6, 16, 10, 0, 0)
      ctx[:proveedor_hora] = instance_double('ProveedorHora', ahora: ctx[:hora_base])
      allow(ctx[:proveedor_hora]).to receive(:construir_hora_utc) do |anio, mes, dia, hora, min|
        Time.utc(anio, mes, dia, hora, min)
      end

      allow(ctx[:proveedor_hora]).to receive(:construir_hora_desde_local) do |anio, mes, dia, hora, min|
        # Simula conversión de horario local a UTC (ejemplo: UTC-3)
        Time.utc(anio, mes, dia, hora + 3, min)
      end

      allow(ctx[:proveedor_hora]).to receive(:cambiar_a_huso_horario_local) do |fecha_utc|
        # Simula conversión de UTC a hora local (ejemplo: UTC-3)
        fecha_utc - 3 * 60 * 60
      end

      # ProveedorDia mock
      ctx[:proveedor_dia] = instance_double('ProveedorDia', hoy: Date.parse('2025-06-16'))
      allow(ctx[:proveedor_dia]).to receive(:cambiar_a_huso_horario_local) do |fecha_utc|
        # para simular hora local solo restamos 3 horas (UTC-3)
        fecha_utc - 3 * 60 * 60
      end

      # Turno mock ocupado a las 10:30 UTC
      turno_mock_utc = ctx[:proveedor_hora].construir_hora_utc(2025, 6, 16, 10, 30)
      ctx[:turno_mock] = { fecha_hora: turno_mock_utc }

      # Turno registrado para usuario
      turno_usuario = Turno.new(
        ctx[:medico],
        ctx[:usuario],
        ctx[:proveedor_hora].construir_hora_utc(2025, 6, 5, 10, 0)
      )

      ctx[:repositorio_turnos] = instance_double(
        'RepositorioTurnos',
        all: [],
        buscar_por_usuario: [turno_usuario],
        buscar_por_medico: [turno_usuario]
      )

      ctx[:proveedor_feriados] = instance_double('ProveedorFeriadosDummy', feriados: [{ dia: 16, mes: 6 }])

      ctx[:gestor_turnos] = described_class.new(
        ctx[:repositorio_turnos],
        ctx[:proveedor_dia],
        ctx[:proveedor_feriados],
        ctx[:proveedor_hora]
      )
    end
  end

  def hora_utc(anio, mes, dia, hora, minuto = 0)
    contexto[:proveedor_hora].construir_hora_utc(anio, mes, dia, hora, minuto)
  end

  def stub_turnos_existentes(turnos)
    allow(contexto[:repositorio_turnos]).to receive(:obtener_turnos_existentes).and_return(turnos)
  end

  it 'deberia devolver turnos disponibles para el médico' do
    stub_turnos_existentes([])
    turnos = contexto[:gestor_turnos].disponibilidad_de_medico(contexto[:medico])
    expect(turnos).not_to be_empty
    expect(turnos.size).to be <= TURNOS_DISPONIBLES
  end

  it 'deberia excluir turnos ya ocupados del listado de disponibles' do
    stub_turnos_existentes([contexto[:turno_mock]])
    turnos = contexto[:gestor_turnos].disponibilidad_de_medico(contexto[:medico])
    expect(turnos).not_to include(contexto[:proveedor_dia].cambiar_a_huso_horario_local(contexto[:turno_mock][:fecha_hora]))
  end

  it 'deberia devolver los turnos de un usuario' do
    turnos = contexto[:gestor_turnos].turnos_paciente(contexto[:usuario].email)
    expect(turnos.size).to eq(1)
    expect(turnos.first.usuario.email).to eq(contexto[:usuario].email)
  end

  it 'deberia devolver 0 turnos si el medico no tiene turnos registrados' do
    allow(contexto[:repositorio_turnos]).to receive(:buscar_por_medico).with(contexto[:medico]).and_return([])
    turnos = contexto[:gestor_turnos].turnos_medico(contexto[:medico])
    expect(turnos).to be_empty
  end

  it 'deberia devolver 1 turno si el medico tiene 1 turno' do
    turnos = contexto[:gestor_turnos].turnos_medico(contexto[:medico])
    expect(turnos.size).to eq(1)
  end

  #=======================================================================================================#

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
    let(:usuario) { Usuario.new('otro@mail.com') }

    let(:turnos) do
      (1..30).map do |i|
        Turno.new(
          Medico.new('Medico', 'Apellido', i, Especialidad.new('Traumatologia', 10)),
          usuario,
          Time.utc(2025, 6, 1) + i * 3600
        )
      end
    end

    before(:each) do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).and_return(turnos)
    end

    it 'devuelve como máximo 20 turnos' do
      result = contexto[:gestor_turnos].turnos_paciente(usuario.email)
      expect(result.size).to be <= 20
    end

    it 'devuelve los turnos ordenados por fecha descendente' do
      result = contexto[:gestor_turnos].turnos_paciente(usuario.email)
      fechas = result.map(&:fecha_hora)
      expect(fechas).to eq(fechas.sort.reverse)
    end

    it 'devuelve los 20 turnos más próximos' do
      result = contexto[:gestor_turnos].turnos_paciente(usuario.email)
      fechas_esperadas = turnos.map(&:fecha_hora).sort.reverse.first(20)
      expect(result.map(&:fecha_hora)).to eq(fechas_esperadas)
    end

    def stub_turno_duplicado(contexto, medico, fecha_hora_utc)
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_medico).with(medico).and_return([
                                                                                                    Turno.new(medico, usuario, fecha_hora_utc)
                                                                                                  ])
    end

    it 'no deberia guardar turnos duplicados' do
      medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10))

      stub_turno_duplicado(contexto, medico, hora_utc(2025, 6, 5, 10, 0))

      expect do
        contexto[:gestor_turnos].crear_turno(medico, usuario, '2025-06-05', '10:00')
      end.to raise_error(TurnoYaExisteException)
    end
  end

  #=======================================================================================================#

  context 'when hay más de 20 turnos para un medico' do
    let(:especialidad) { Especialidad.new('Traumatologia', 10) }
    let(:medico) { Medico.new('Michael', 'Jordan', '1', especialidad) }
    let(:turnos) do
      (1..30).reverse_each.map do |i|
        Turno.new(
          medico,
          Usuario.new('usuario@prueba.com'),
          Time.utc(2025, 6, 1) + i * 3600
        )
      end
    end

    before(:each) do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_medico).with(medico).and_return(turnos)
    end

    it 'devuelve los turnos de medicos ordenados por fecha' do
      result = contexto[:gestor_turnos].turnos_medico(medico)
      fechas = result.map(&:fecha_hora)
      expect(fechas).to eq(fechas.sort.reverse)
    end

    it 'devuelve solo 20 turnos de un medico' do
      result = contexto[:gestor_turnos].turnos_medico(medico)
      expect(result.size).to be <= 20
    end
  end

  #=======================================================================================================#
  describe '#proximos_turnos_paciente' do
    let(:especialidad) { instance_double('Especialidad', nombre: 'Traumatologia', duracion_de_turnos: 10) }
    let(:medico) { instance_double('Medico', nombre: 'Medico', apellido: 'Apellido', matricula: 1, especialidad:) }
    let(:usuario) { instance_double('Usuario', email: 'paciente@mail.com') }

    before(:each) do
      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(hora_utc(2025, 6, 16, 15))
    end

    context 'when hay turnos antes y después de la hora actual' do
      let(:turnos) do
        [
          instance_double('Turno', medico:, usuario:, fecha_hora: hora_utc(2025, 6, 16, 14), estado: 'Pendiente', id: 1),
          instance_double('Turno', medico:, usuario:, fecha_hora: hora_utc(2025, 6, 16, 15), estado: 'Pendiente', id: 2),
          instance_double('Turno', medico:, usuario:, fecha_hora: hora_utc(2025, 6, 16, 16), estado: 'Pendiente', id: 3)
        ]
      end

      before(:each) do
        allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).with(usuario).and_return(turnos)
      end

      it 'devuelve solo los turnos desde la hora actual en adelante, ordenados por fecha y hora' do
        result = contexto[:gestor_turnos].proximos_turnos_paciente(usuario)
        expect(result.size).to eq(2)
        expect(result.map(&:fecha_hora)).to eq([hora_utc(2025, 6, 16, 15), hora_utc(2025, 6, 16, 16)])
        expect(result.map(&:id)).to eq([2, 3])
      end
    end

    context 'when hay turnos cancelados' do
      let(:turnos) do
        [
          instance_double('Turno', medico:, usuario:, fecha_hora: hora_utc(2025, 6, 16, 15), estado: 'Pendiente', id: 1),
          instance_double('Turno', medico:, usuario:, fecha_hora: hora_utc(2025, 6, 16, 16), estado: 'Cancelado', id: 2),
          instance_double('Turno', medico:, usuario:, fecha_hora: hora_utc(2025, 6, 16, 17), estado: 'Pendiente', id: 3)
        ]
      end

      before(:each) do
        allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).with(usuario).and_return(turnos)
      end

      it 'devuelve solo los turnos pendientes, no los cancelados' do
        result = contexto[:gestor_turnos].proximos_turnos_paciente(usuario)
        expect(result.size).to eq(2)
        expect(result.map(&:estado)).to all(eq('Pendiente'))
        expect(result.map(&:id)).to eq([1, 3])
      end
    end

    context 'when no hay próximos turnos' do
      let(:turnos) { [] }

      before(:each) do
        allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).with(usuario).and_return(turnos)
      end

      it 'lanza NoHayProximosTurnosException si no hay próximos turnos' do
        expect do
          contexto[:gestor_turnos].proximos_turnos_paciente(usuario)
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
          fecha_hora: hora_utc(2025, 11, 1, 10)
        ),
        pasado: instance_double(
          'Turno',
          id: 3,
          estado: ESTADO_PENDIENTE,
          fecha_hora: hora_utc(2025, 1, 1, 10)
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
      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(hora_utc(2025, 6, 10, 9))
      expect(turnos[:futuro]).to receive(:estado=).with(ESTADO_CANCELADO)
      result = contexto[:gestor_turnos].modificar_estado_turno(2, ESTADO_CANCELADO)
      expect(result).to eq(turnos[:futuro])
    end

    it 'no permite cancelar un turno pasado' do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_id).with(3).and_return(turnos[:pasado])
      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(hora_utc(2025, 6, 10, 9))
      expect { contexto[:gestor_turnos].modificar_estado_turno(3, ESTADO_CANCELADO) }.to raise_error(TurnoYaPasadoException)
    end

    it 'permite marcar como asistido un turno pasado' do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_id).with(3).and_return(turnos[:pasado])
      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(hora_utc(2025, 6, 10, 9))
      expect(turnos[:pasado]).to receive(:estado=).with(ESTADO_ASISTIDO)
      result = contexto[:gestor_turnos].modificar_estado_turno(3, ESTADO_ASISTIDO)
      expect(result).to eq(turnos[:pasado])
    end

    it 'no permite marcar como asistido un turno futuro' do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_id).with(2).and_return(turnos[:futuro])
      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(hora_utc(2025, 1, 1, 9))
      expect { contexto[:gestor_turnos].modificar_estado_turno(2, ESTADO_ASISTIDO) }.to raise_error(TurnoFuturoException)
    end

    it 'no se puede modificar el estado de un turno que no sea pendiente' do
      allow(turnos[:futuro]).to receive(:estado).and_return(ESTADO_ASISTIDO)
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_id).with(2).and_return(turnos[:futuro])
      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(hora_utc(2025, 6, 10, 9))
      expect { contexto[:gestor_turnos].modificar_estado_turno(2, ESTADO_CANCELADO) }.to raise_error(EstadoNoPermitidoException)
    end

    it 'debería tirar error si el id no es un entero' do
      expect { contexto[:gestor_turnos].modificar_estado_turno('abc', ESTADO_CANCELADO) }.to raise_error(ArgumentError)
    end
  end

  describe 'Historial de turnos' do
    let(:usuario) { instance_double('Usuario', email: 'pepe@mail.com', telegram_id: 123_456_789) }

    let(:turnos) do
      [
        instance_double('Turno', estado: 'Asistido', fecha_hora: hora_utc(2025, 6, 13, 14), id: 1),
        instance_double('Turno', estado: 'Asistido', fecha_hora: hora_utc(2025, 6, 17, 14), id: 2),
        instance_double('Turno', estado: 'Asistido', fecha_hora: hora_utc(2025, 6, 10, 14), id: 3)
      ]
    end

    it 'lanza NoHayHistorialTurnosException si el paciente nunca reservó turnos' do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).and_return([])
      expect do
        contexto[:gestor_turnos].historial_turnos_paciente(123_456_789)
      end.to raise_error(NoHayHistorialTurnosException)
    end

    it 'devuelve un turno con estado "Ausente" si el paciente no asistió' do
      turno = instance_double('Turno', estado: 'Ausente', fecha_hora: hora_utc(2025, 6, 13, 14))
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).and_return([turno])

      historial = contexto[:gestor_turnos].historial_turnos_paciente(usuario)
      expect(historial.first.estado).to eq('Ausente')
    end

    it 'devuelve un turno con estado "Asistido" si el paciente asistió' do
      turno = instance_double('Turno', estado: 'Asistido', fecha_hora: hora_utc(2025, 6, 13, 14))
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).and_return([turno])

      historial = contexto[:gestor_turnos].historial_turnos_paciente(usuario)
      expect(historial.first.estado).to eq('Asistido')
    end

    it 'devuelve un turno con estado "Cancelado" si el paciente lo canceló' do
      turno = instance_double('Turno', estado: 'Cancelado', fecha_hora: hora_utc(2025, 6, 13, 14))
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).and_return([turno])

      historial = contexto[:gestor_turnos].historial_turnos_paciente(usuario)
      expect(historial.first.estado).to eq('Cancelado')
    end

    it 'devuelve los turnos pasados ordenados por fecha descendente' do
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).and_return(turnos)

      historial = contexto[:gestor_turnos].historial_turnos_paciente(usuario)
      expect(historial).to eq(turnos.sort_by(&:fecha_hora).reverse)
    end

    it 'devuelve como máximo 15 turnos' do
      muchos_turnos = (0...20).map do |i|
        instance_double('Turno', estado: 'Asistido', fecha_hora: hora_utc(2025, 6, 16, 9 + i / 2, (i % 2) * 30))
      end

      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_usuario).and_return(muchos_turnos)
      expect(contexto[:gestor_turnos].historial_turnos_paciente(usuario).size).to eq(MAXIMA_CANTIDAD_TURNOS_HISTORIAL_VISIBLES)
    end
  end

  describe 'Cancelar turnos' do
    let(:usuario) { instance_double('Usuario', email: 'pepe@mail.com', telegram_id: 123_456_789) }

    it 'devuelve false si el turno no ocurre en las próximas 24hs' do
      ahora = hora_utc(2025, 6, 13, 14)
      turno = instance_double('Turno', estado: 'Cancelado', fecha_hora: hora_utc(2025, 6, 15, 14))

      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(ahora)
      allow(turno).to receive(:proximas_24hs?).with(ahora).and_return(false)

      expect(contexto[:gestor_turnos].ocurre_proximas_24hs?(turno)).to eq(false)
    end

    it 'devuelve true si el turno ocurre en las próximas 24hs' do
      ahora = hora_utc(2025, 6, 13, 14)
      turno = instance_double('Turno', estado: 'Cancelado', fecha_hora: hora_utc(2025, 6, 14, 12))

      allow(contexto[:proveedor_hora]).to receive(:ahora).and_return(ahora)
      allow(turno).to receive(:proximas_24hs?).with(ahora).and_return(true)

      expect(contexto[:gestor_turnos].ocurre_proximas_24hs?(turno)).to eq(true)
    end

    it 'cancelar turno lo deja con estado Cancelado si se hace con 24hs de anticipacion' do
      fecha_turno = contexto[:proveedor_hora].ahora + 12 * 60 * 60
      turno_id = 1
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_id).with(1).and_return(Turno.new('medicoDummy', 'usuarioDummy', fecha_turno))
      allow(contexto[:repositorio_turnos]).to receive(:save).with(instance_of(Turno))
      expect(contexto[:gestor_turnos].cancelar_turno(turno_id).estado).to eq('Cancelado')
    end

    it 'cancelar turno lo deja con estado Ausente si se hace con menos de 24hs de anticipacion' do
      fecha_turno = contexto[:proveedor_hora].ahora + 36 * 60 * 60
      turno_id = 1
      allow(contexto[:repositorio_turnos]).to receive(:buscar_por_id).with(1).and_return(Turno.new('medicoDummy', 'usuarioDummy', fecha_turno))
      allow(contexto[:repositorio_turnos]).to receive(:save).with(instance_of(Turno))
      expect(contexto[:gestor_turnos].cancelar_turno(turno_id).estado).to eq('Ausente')
    end
  end
end
