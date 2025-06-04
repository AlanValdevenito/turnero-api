require 'integration_helper'
require_relative '../../dominio/turnero'
require_relative '../../dominio/medico'

describe Turnero do
  subject(:turnero) { described_class.new(repositorios[:usuario], repositorios[:medico], repositorios[:especialidad], repositorios[:turnos]) }

  let(:email) { 'test@email.com' }

  let(:repositorios) do
    {
      usuario: instance_double('RepositorioUsuarios', buscar_por_email: Usuario.new('Juan@mail.com')),
      medico: instance_double('repositorios_medicos', save: Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10)), all: [Medico.new('Michael', 'Jordan', 1, 'Traumatologia')]),
      especialidad: instance_double('RepositorioEspecialidades', save: Especialidad.new('Traumatologia', 10), all: [Especialidad.new('Traumatologia', 10)],
                                                                 buscar_por_nombre: Especialidad.new('Traumatologia', 10)),
      turnos: instance_double('RepositorioTurnos', all: [],
                                                   buscar_por_usuario: [Turno.new(Medico.new('Medico1', 'Apellido1', 'ABC123', Especialidad.new('Traumatologia', 10)),
                                                                                  Usuario.new('Juan@mail.com'),
                                                                                  DateTime.parse('2025-06-05T10:00:00'))])
    }
  end

  let(:turno_mock) { { fecha_hora: Time.now + 3600 } }

  def stub_turnos_existentes(turnos)
    allow(repositorios[:turnos]).to receive(:obtener_turnos_existentes).and_return(turnos)
  end

  def stub_usuario_no_existente(repositorio, email, telegram_id = nil)
    allow(repositorio).to receive(:save).with(instance_of(Usuario))
    allow(repositorio).to receive(:buscar_por_email).with(email).and_return(nil)
    allow(repositorio).to receive(:buscar_por_telegram_id).with(telegram_id).and_return(nil) if telegram_id
  end

  it 'deberia crear un medico' do
    medico = turnero.crear_medico('Michael', 'Jordan', 1, 'Traumatologia')
    expect(medico.nombre).to eq('Michael')
  end

  it 'deberia devolver error si el email ya existe al crear un usuario' do
    allow(repositorios[:usuario]).to receive(:buscar_por_email).with(email).and_return(Usuario.new(email, 1))

    expect { turnero.crear_usuario(email) }.to raise_error(EmailEnUsoException)
  end

  it 'deberia buscar un usuario por email' do
    usuario_mock = Usuario.new(email, 1)

    allow(repositorios[:usuario]).to receive(:buscar_por_email).with(email).and_return(usuario_mock)

    usuario = turnero.buscar_usuario_por_email(email)
    expect(usuario).to eq(usuario_mock)
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

  it 'deberia crear un usuario' do
    stub_usuario_no_existente(repositorios[:usuario], email, 123_456_789)
    created_user = turnero.crear_usuario(email, 123_456_789)
    expect(created_user.email).to eq(email)
    expect(created_user.telegram_id).to eq(123_456_789)
  end

  it 'deberia devolver error si el telegram_id ya existe al crear un usuario' do
    allow(repositorios[:usuario]).to receive(:buscar_por_email).with(email).and_return(nil)
    allow(repositorios[:usuario]).to receive(:buscar_por_telegram_id).with(123_456_789).and_return(Usuario.new(email, 1, 123_456_789))

    expect { turnero.crear_usuario(email, 123_456_789) }.to raise_error(TelegramIdEnUsoException)
  end

  it 'deberia devolver error si el email es nil al crear un usuario' do
    stub_usuario_no_existente(repositorios[:usuario], nil)
    expect { turnero.crear_usuario(nil) }.to raise_error(EmailObligatorioException)
  end

  it 'deberia devolver error si el email es vacío al crear un usuario' do
    stub_usuario_no_existente(repositorios[:usuario], '')
    expect { turnero.crear_usuario('') }.to raise_error(EmailObligatorioException)
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

  it 'debería devolver error si el médico no existe' do
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with(999).and_return(nil)

    expect { turnero.disponibilidad_de_medico(999) }.to raise_error(MedicoNoEncontradoException)
  end

  it 'debería devolver turnos disponibles para el médico' do
    medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10))
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with(1).and_return(medico)

    stub_turnos_existentes([])

    turnos_disponibles = turnero.disponibilidad_de_medico(1)
    expect(turnos_disponibles.size).to be <= TURNOS_DISPONIBLES
  end

  it 'debería devolver turnos disponibles cuando algunos turnos ya están ocupados' do
    medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10))
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with(1).and_return(medico)

    stub_turnos_existentes([turno_mock])
    turnos_disponibles = turnero.disponibilidad_de_medico(1)
    expect(turnos_disponibles).not_to include(turno_mock[:fecha_hora])
  end

  it 'deberia devolver turnos disponibles de un usuario' do
    usuario = Usuario.new('Juan@mail.com')
    turnos = turnero.turnos(usuario.email)
    expect(turnos.first.usuario.email).to eq(usuario.email)
  end
end
