require 'integration_helper'
Dir[File.join(__dir__, '../../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../dominio/excepciones', '*.rb')].each { |file| require file }

describe Turnero do
  subject(:turnero) do
    described_class.new(repositorios[:usuario], repositorios[:medico], repositorios[:especialidad], repositorios[:turnos], proveedores[:fecha], proveedores[:feriados])
  end

  before(:each) do
    stub_const('PROXIMAS_24HS_FALSE', false)
    allow_any_instance_of(GestorUsuarios).to receive(:actualizar).and_return(nil)
    allow_any_instance_of(RepositorioUsuarios).to receive(:save).and_return(nil)
  end

  let(:email) { 'test@email.com' }

  let(:repositorios) do
    {
      usuario: instance_double('RepositorioUsuarios', buscar_por_email: Usuario.new('Juan@mail.com')),
      medico: instance_double('repositorios_medicos', save: Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10, 5)), all: [Medico.new('Michael', 'Jordan', 1, 'Traumatologia')],
                                                      buscar_por_matricula: [Medico.new('Medico1', 'Apellido1', 'ABC123', Especialidad.new('Traumatologia', 10, 5))],
                                                      buscar_por_especialidad: [Medico.new('Medico2', 'Apellido2', 'XYZ123', Especialidad.new('Traumatologia', 10, 5))]),
      especialidad: instance_double('RepositorioEspecialidades', save: Especialidad.new('Traumatologia', 10, 5), all: [Especialidad.new('Traumatologia', 10, 5)],
                                                                 buscar_por_nombre: Especialidad.new('Traumatologia', 10, 5)),
      turnos: instance_double('RepositorioTurnos')
    }
  end

  let(:proveedores) do
    {
      feriados: instance_double('ProveedorFeriadosDummy', feriados: [{ "dia": 16, "mes": 6 }]),
      fecha: instance_double('ProveedorFecha', ahora: Time.new(2025, 6, 16, 10, 0, 0))
    }
  end

  it 'deberia crear un medico' do
    medico = turnero.crear_medico('Michael', 'Jordan', 1, 'Traumatologia')
    expect(medico.nombre).to eq('Michael')
  end

  it 'deberia devolver todos los medicos' do
    medicos = turnero.medicos
    expect(medicos.first.nombre).to eq('Michael')
  end

  it 'deberia crear una especialidad' do
    especialidad = turnero.crear_especialidad('Traumatologia', 10, 5)
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
    medico = Medico.new('Michael', 'Jordan', 1, Especialidad.new('Traumatologia', 10, 5))
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with(1).and_return(medico)
    encontrado = turnero.buscar_medico_por_matricula(1)
    expect(encontrado).to eq(medico)
  end

  it 'deberia devolver error si el médico no existe' do
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with(999).and_return(nil)

    expect { turnero.disponibilidad_de_medico(999) }.to raise_error(MedicoNoEncontradoException)
  end

  it 'deberia devolver error si el usuario no existe' do
    allow(repositorios[:usuario]).to receive(:buscar_por_email).with(email).and_return(nil)

    expect { turnero.turnos_paciente(email) }.to raise_error(UsuarioNoEncontradoException)
  end

  it 'deberia devolver error al consultar turnos si el medico no existe' do
    allow(repositorios[:medico]).to receive(:buscar_por_matricula).with('ABC123').and_return(nil)

    expect { turnero.turnos_medico('ABC123') }.to raise_error(MedicoNoEncontradoException)
  end

  describe 'Reserva de turno por especialidad ' do
    it 'deberia devolver los medicos disponibles de una especialidad' do
      traumatologos_disponibles = turnero.medicos_disponibles_especialidad('Traumatologia')
      expect(traumatologos_disponibles.first.matricula).to eq('XYZ123')
      expect(traumatologos_disponibles.first.especialidad.nombre).to eq('Traumatologia')
    end

    it 'deberia devolver como maximo 7 medicos disponibles de una especialidad' do
      allow(repositorios[:medico]).to receive(:buscar_por_especialidad).and_return(
        (0...10).map { |i| Medico.new("Medico#{i}", "Apellido#{i}", "ABC#{i}", Especialidad.new('Traumatologia', 10, 5)) }
      )

      traumatologos_disponibles = turnero.medicos_disponibles_especialidad('Traumatologia')
      expect(traumatologos_disponibles.size).to be <= 7
    end

    it 'deberia devolver error al consultar turnos si la especialidad no tiene medicos dados de alta' do
      allow(repositorios[:medico]).to receive(:buscar_por_especialidad).and_return([])
      expect { turnero.medicos_disponibles_especialidad('Traumatologia') }.to raise_error(EspecialidadSinMedicosException)
    end
  end

  describe 'Historial de turnos' do
    it 'deberia lanzar excepcion NoHayHistorialTurnosException si el paciente nunca reservo turnos' do
      usuario = instance_double('Usuario', email: 'pepe@mail.com')
      allow(repositorios[:usuario]).to receive(:buscar_por_email).with('pepe@mail.com').and_return(usuario)
      allow(repositorios[:turnos]).to receive(:buscar_por_usuario).with(usuario).and_return([])
      expect { turnero.historial_turnos_paciente('pepe@mail.com') }.to raise_error(NoHayHistorialTurnosException)
    end
  end

  describe 'Cancelar turnos' do
    it 'cancelar turno devuelve un turno cancelado si se hace con mas de 24hs de anticipacion' do
      fecha_turno = proveedores[:fecha].ahora + 36 * 60 * 60
      usuario = Usuario.new('usuario@mail.com')
      allow(repositorios[:turnos]).to receive(:buscar_por_id).with(1).and_return(Turno.new('medico', usuario, fecha_turno))
      allow(repositorios[:turnos]).to receive(:save).with(instance_of(Turno))
      expect(turnero.cancelar_turno(1, PROXIMAS_24HS_FALSE, usuario.email).estado).to eq('Cancelado')
    end

    it 'cancelar turno devuelve un turno ausente si se hace con menos de 24hs de anticipacion' do
      fecha_turno = proveedores[:fecha].ahora + 12 * 60 * 60
      usuario = Usuario.new('usuario@mail.com')
      allow(repositorios[:turnos]).to receive(:buscar_por_id).with(1).and_return(Turno.new('medico', usuario, fecha_turno))
      allow(repositorios[:turnos]).to receive(:save).with(instance_of(Turno))
      expect(turnero.cancelar_turno(1, 'proximas', usuario.email).estado).to eq('Ausente')
    end
  end

  describe 'Eliminar usuario' do
    it 'deberia delegar al gestor de usuarios para eliminar el usuario por email' do
      gestor_mock = instance_double('GestorUsuarios')
      turnero.instance_variable_set(:@gestor_usuarios, gestor_mock)
      expect(gestor_mock).to receive(:eliminar_usuario_por_email).with(email)
      turnero.eliminar_usuario_por_email(email)
    end
  end
end
