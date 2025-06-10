require 'integration_helper'
Dir[File.join(__dir__, '../../dominio', '*.rb')].each { |file| require file }

describe Turnero do
  subject(:turnero) do
    described_class.new(repositorios[:usuario], repositorios[:medico], repositorios[:especialidad], repositorios[:turnos], proveedores[:dia], proveedores[:feriados], proveedores[:hora])
  end

  let(:email) { 'test@email.com' }

  let(:repositorios) do
    {
      usuario: instance_double('RepositorioUsuarios', buscar_por_email: Usuario.new('Juan@mail.com')),
      medico: instance_double('repositorios_medicos', save: Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10)), all: [Medico.new('Michael', 'Jordan', 1, 'Traumatologia')],
                                                      buscar_por_matricula: [Medico.new('Medico1', 'Apellido1', 'ABC123', Especialidad.new('Traumatologia', 10))]),
      especialidad: instance_double('RepositorioEspecialidades', save: Especialidad.new('Traumatologia', 10), all: [Especialidad.new('Traumatologia', 10)],
                                                                 buscar_por_nombre: Especialidad.new('Traumatologia', 10)),
      turnos: instance_double('RepositorioTurnos', all: [],
                                                   buscar_por_usuario: [Turno.crear(Medico.new('Medico1', 'Apellido1', 'ABC123', Especialidad.new('Traumatologia', 10)),
                                                                                    Usuario.new('Juan@mail.com'),
                                                                                    '2025-06-05', '10:00')],
                                                   buscar_por_medico: [Turno.crear(Medico.new('Medico1', 'Apellido1', 'ABC123', Especialidad.new('Traumatologia', 10)),
                                                                                   Usuario.new('Juan@mail.com'),
                                                                                   '2025-06-05', '10:00')])
    }
  end

  let(:proveedores) do
    {
      dia: instance_double('ProveedorDia', hoy: Date.parse('2025-06-16')),
      feriados: instance_double('ProveedorFeriadosDummy'),
      hora: instance_double(
        'ProveedorHora',
        ahora: Time.new(2025, 6, 16, 10, 0, 0),
        construir_hora: Time.new(2025, 6, 16, 10, 0, 0)
      )
    }
  end

  let(:turno_mock) { { fecha_hora: Time.now + 3600 } }

  def stub_turnos_existentes(turnos)
    allow(repositorios[:turnos]).to receive(:obtener_turnos_existentes).and_return(turnos)
  end

  def stub_feriados_api
    stub_request(:get, 'https://nolaborables.com.ar/api/v2/feriados/2025')
      .to_return(status: 200, body: '[{ "dia": 16, "mes": 6 }]', headers: {})
  end

  before(:each) do
    stub_feriados_api
  end

  it 'deberia crear un medico' do
    medico = turnero.crear_medico('Michael', 'Jordan', 1, 'Traumatologia')
    expect(medico.nombre).to eq('Michael')
  end

  it 'deberia devolver error si el email ya existe al crear un usuario' do
    allow(repositorios[:usuario]).to receive(:buscar_por_email).with(email).and_return(Usuario.new(email, 1))

    expect { turnero.crear_usuario(email) }.to raise_error(EmailEnUsoException)
  end

  it 'deberia devolver todos los medicos' do
    medicos = turnero.medicos
    expect(medicos.first.nombre).to eq('Michael')
  end

  it 'deberia crear una especialidad' do
    especialidad = turnero.crear_especialidad('Traumatologia', 10)
    expect(especialidad.nombre).to eq('Traumatologia')
  end

  it 'deberia devolver todas las especialidades' do
    especialidades = turnero.especialidades
    expect(especialidades.first.nombre).to eq('Traumatologia')
  end

  it 'deberia crear un medico con especialidad' do
    medico = turnero.crear_medico('Michael', 'Jordan', 1, 'Traumatologia')
    expect(medico.especialidad.nombre).to eq('Traumatologia')
  end

  it 'deberia devolver los medicos disponibles' do
    medicos_disponibles = turnero.medicos_disponibles
    expect(medicos_disponibles.size).to be <= 7
    expect(medicos_disponibles.first.apellido).to eq('Jordan')
    expect(medicos_disponibles.first.matricula).to eq(1)
  end

  it 'deberia buscar un medico por matricula' do
    medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10))
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with(1).and_return(medico)
    encontrado = turnero.buscar_medico_por_matricula(1)
    expect(encontrado).to eq(medico)
  end

  def stub_turnos_existentes(turnos)
    allow(repositorios[:turnos]).to receive(:obtener_turnos_existentes).and_return(turnos)
  end

  it 'deberia devolver error si el médico no existe' do
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with(999).and_return(nil)

    expect { turnero.disponibilidad_de_medico(999) }.to raise_error(MedicoNoEncontradoException)
  end

  it 'deberia devolver turnos disponibles para el médico' do
    medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10))
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with(1).and_return(medico)

    stub_turnos_existentes([])

    turnos_disponibles = turnero.disponibilidad_de_medico(1)
    expect(turnos_disponibles.size).to be <= TURNOS_DISPONIBLES
  end

  it 'deberia devolver turnos disponibles cuando algunos turnos ya están ocupados' do
    medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10))
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with(1).and_return(medico)

    stub_turnos_existentes([turno_mock])
    turnos_disponibles = turnero.disponibilidad_de_medico(1)
    expect(turnos_disponibles).not_to include(turno_mock[:fecha_hora])
  end

  it 'deberia devolver turnos disponibles de un usuario' do
    usuario = Usuario.new('Juan@mail.com')
    turnos = turnero.turnos_paciente(usuario.email)
    expect(turnos.first.usuario.email).to eq(usuario.email)
  end

  it 'deberia devolver 0 turnos disponibles de un medico si no tiene turnos' do
    repositorio_turnos_vacio = instance_double('RepositorioTurnos', buscar_por_medico: [])
    turnero_vacio = described_class.new(repositorios[:usuario], repositorios[:medico],
                                        repositorios[:especialidad], repositorio_turnos_vacio, proveedores[:dia], proveedores[:feriados], proveedores[:hora])

    turnos = turnero_vacio.turnos_medico('ABC123')
    expect(turnos.size).to eq(0)
  end

  it 'deberia devolver 1 turno disponible de un medico que tiene 1 turno' do
    especialidad = Especialidad.new('Traumatologia', 10)
    medico = Medico.new('Medico1', 'Apellido1', 'ABC123', especialidad)
    turnos = turnero.turnos_medico(medico.matricula)
    expect(turnos.size).to eq(1)
  end

  def stub_usuario_telegram
    allow(repositorios[:usuario])
      .to receive(:buscar_por_telegram_id)
      .with(123_456_789)
      .and_return(Usuario.new(email, nil, 123_456_789))
  end

  def stub_medico_matricula
    allow(repositorios[:medico])
      .to receive(:buscar_por_matricula)
      .with('1')
      .and_return(Medico.new('Michael', 'Jordan', '1', Especialidad.new('Traumatologia', 10)))
  end

  def stub_turnos_por_medico
    allow(repositorios[:turnos])
      .to receive(:buscar_por_medico)
      .with(instance_of(Medico))
      .and_return([])
  end

  def stub_turno_save
    allow(repositorios[:turnos])
      .to receive(:save)
      .with(instance_of(Turno)) { |turno| turno }
  end

  def stub_crear_turno_ok
    stub_usuario_telegram
    stub_medico_matricula
    stub_turnos_por_medico
    stub_turno_save
  end

  it 'deberia crear un turno correctamente' do
    stub_crear_turno_ok
    turno = turnero.crear_turno('1', '2025-06-05', '10:00', 123_456_789)
    expect(turno.fecha).to eq('2025-06-05')
  end

  it 'deberia devolver error si el usuario no existe' do
    allow(repositorios[:usuario]).to receive(:buscar_por_email).with(email).and_return(nil)

    expect { turnero.turnos_paciente(email) }.to raise_error(UsuarioNoEncontradoException)
  end

  it 'deberia devolver error al consultar turnos si el medico no existe' do
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with('ABC123').and_return(nil)

    expect { turnero.turnos_medico('ABC123') }.to raise_error(MedicoNoEncontradoException)
  end

  context 'when hay más de 20 turnos para un usuario' do
    usuario = Usuario.new('pepe@mail.com')
    turnos = (1..30).map do |i|
      Turno.new(
        Medico.new('Medico', 'Apellido', i, Especialidad.new('Traumatologia', 10)),
        usuario,
        DateTime.now + i
      )
    end

    before(:each) do
      allow(repositorios[:usuario]).to receive(:buscar_por_email).with(usuario.email).and_return(usuario)
      allow(repositorios[:turnos]).to receive(:buscar_por_usuario).with(usuario).and_return(turnos)
      allow(repositorios[:medico]).to receive(:buscar_por_matricula).with('1').and_return(Medico.new('Michael', 'Jordan', '1', Especialidad.new('Traumatologia', 10)))
      allow(repositorios[:usuario]).to receive(:buscar_por_telegram_id).with(123_456_789).and_return(usuario)
    end

    it 'devuelve como máximo 20 turnos' do
      turnos = turnero.turnos_paciente(usuario.email)
      expect(turnos.size).to be <= 20
    end

    it 'devuelve los turnos ordenados por fecha' do
      turnos = turnero.turnos_paciente(usuario.email)
      fechas = turnos.map(&:fecha_hora)
      expect(fechas).to eq(fechas.sort)
    end

    it 'devuelve los 20 turnos más próximos' do
      turnos = turnero.turnos_paciente(usuario.email)
      fechas = turnos.map(&:fecha_hora)
      expect(fechas).to eq(turnos.map(&:fecha_hora).sort.first(20))
    end

    it 'no deberia guardar turnos duplicados' do
      allow(repositorios[:turnos]).to receive(:buscar_por_medico).with(instance_of(Medico)).and_return([])
      allow(repositorios[:turnos]).to receive(:save).with(instance_of(Turno)).and_raise(TurnoYaExisteException)
      expect do
        turnero.crear_turno('1', '2025-06-05', '10:00', 123_456_789)
      end.to raise_error(TurnoYaExisteException)
    end
  end

  context 'when hay más de 20 turnos para un medico' do
    medico = Medico.new('Michael', 'Jordan', '1', Especialidad.new('Traumatologia', 10))

    turnos = (1..30).reverse_each.map do |i|
      Turno.new(
        medico,
        Usuario.new('usuario@prueba.com'),
        DateTime.now + i
      )
    end

    before(:each) do
      allow(repositorios[:medico]).to receive(:buscar_por_matricula).with(medico.matricula).and_return(medico)
      allow(repositorios[:turnos]).to receive(:buscar_por_medico).with(medico).and_return(turnos)
    end

    it 'devuelve los turnos de medicos ordenados por fecha' do
      turnos = turnero.turnos_medico(medico.matricula)
      fechas = turnos.map(&:fecha_hora)
      expect(fechas).to eq(fechas.sort)
    end

    it 'devuelve solo 20 turnos de un medico' do
      turnos = turnero.turnos_medico(medico.matricula)
      expect(turnos.size).to be <= 20
    end
  end

  describe '#proximos_turnos_paciente con horas' do
    let(:ahora) { DateTime.parse('2025-06-16T15:00:00') }

    before(:each) do
      especialidad = instance_double('Especialidad', nombre: 'Traumatologia', duracion_de_turnos: 10)
      medico = instance_double('Medico', nombre: 'Medico', apellido: 'Apellido', matricula: 1, especialidad:)
      usuario = instance_double('Usuario', email: 'pepe@mail.com', telegram_id: '123456789')
      turnos = [
        instance_double('Turno', medico:, usuario:, fecha_hora: DateTime.parse('2025-06-16T14:00:00'), estado: 'Pendiente', id: 1),
        instance_double('Turno', medico:, usuario:, fecha_hora: DateTime.parse('2025-06-16T15:00:00'), estado: 'Pendiente', id: 2),
        instance_double('Turno', medico:, usuario:, fecha_hora: DateTime.parse('2025-06-16T16:00:00'), estado: 'Pendiente', id: 3)
      ]

      allow(repositorios[:usuario]).to receive(:buscar_por_telegram_id).with('123456789').and_return(usuario)
      allow(repositorios[:turnos]).to receive(:buscar_por_usuario).with(usuario).and_return(turnos)
      allow(turnero.instance_variable_get(:@proveedor_hora)).to receive(:ahora).and_return(ahora)
    end

    it 'devuelve solo los turnos desde la hora actual en adelante, ordenados por fecha y hora' do
      result = turnero.proximos_turnos_paciente('123456789')
      expect(result.size).to eq(2)
      expect(result.map(&:fecha_hora)).to eq([DateTime.parse('2025-06-16T15:00:00'), DateTime.parse('2025-06-16T16:00:00')])
      expect(result.map(&:id)).to eq([2, 3])
    end
  end

  describe '#proximos_turnos_paciente excluye cancelados' do
    let(:ahora) { DateTime.parse('2025-06-16T15:00:00') }

    before(:each) do
      especialidad = instance_double('Especialidad', nombre: 'Traumatologia', duracion_de_turnos: 10)
      medico = instance_double('Medico', nombre: 'Medico', apellido: 'Apellido', matricula: 1, especialidad:)
      usuario = instance_double('Usuario', email: 'pepe@mail.com', telegram_id: '123456789')
      turnos = [
        instance_double('Turno', medico:, usuario:, fecha_hora: DateTime.parse('2025-06-16T15:00:00'), estado: 'Pendiente', id: 1),
        instance_double('Turno', medico:, usuario:, fecha_hora: DateTime.parse('2025-06-16T16:00:00'), estado: 'Cancelado', id: 2),
        instance_double('Turno', medico:, usuario:, fecha_hora: DateTime.parse('2025-06-16T17:00:00'), estado: 'Pendiente', id: 3)
      ]

      allow(repositorios[:usuario]).to receive(:buscar_por_telegram_id).with('123456789').and_return(usuario)
      allow(repositorios[:turnos]).to receive(:buscar_por_usuario).with(usuario).and_return(turnos)
      allow(turnero.instance_variable_get(:@proveedor_hora)).to receive(:ahora).and_return(ahora)
    end

    it 'devuelve solo los turnos pendientes, no los cancelados' do
      result = turnero.proximos_turnos_paciente('123456789')
      expect(result.size).to eq(2)
      expect(result.map(&:estado)).to all(eq('Pendiente'))
      expect(result.map(&:id)).to eq([1, 3])
    end
  end
end
