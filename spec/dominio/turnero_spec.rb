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
      medico: instance_double('repositorios_medicos',
                              save: ->(medico) { medico },
                              all: [],
                              buscar_por_matricula: nil,
                              buscar_por_especialidad: []),
      especialidad: instance_double('RepositorioEspecialidades',
                                    save: ->(especialidad) { especialidad },
                                    all: [Especialidad.new('Traumatologia', 10, 5)],
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

  describe 'crear un medico' do
    before(:each) do
      allow(repositorios[:medico]).to receive(:buscar_por_matricula).and_return(nil)
      allow(repositorios[:medico]).to receive(:save) do |medico|
        medico
      end
    end

    def configurar_medico_existente(medico)
      allow(repositorios[:medico]).to receive(:buscar_por_matricula)
        .with(medico.matricula).and_return(medico)
    end

    def verificar_matriculas_duplicadas(matriculas)
      matriculas.each do |matricula_variacion|
        expect do
          turnero.crear_medico('Carlos', 'Perez', matricula_variacion, 'Traumatologia')
        end.to raise_error(MatriculaDuplicadaException)
      end
    end

    it 'deberia crear un medico' do
      medico = turnero.crear_medico('Michael', 'Jordan', 1, 'Traumatologia')
      expect(medico.nombre).to eq('Michael')
    end

    it 'deberia crear un medico con especialidad' do
      medico = turnero.crear_medico('Michael', 'Jordan', 1, 'Traumatologia')
      expect(medico.especialidad.nombre).to eq('Traumatologia')
    end

    it 'la matricula debe ser unica' do
      medico1 = turnero.crear_medico('Michael', 'Jordan', 'ABC123', 'Traumatologia')

      allow(repositorios[:medico]).to receive(:all).and_return([medico1])

      expect { turnero.crear_medico('Carlos', 'Perez', 'ABC123', 'Traumatologia') }
        .to raise_error(MatriculaDuplicadaException)
    end

    it 'la matricula debe ser unica sin importar mayusculas o acentos' do
      medico1 = turnero.crear_medico('Michael', 'Jordan', 'abc123', 'Traumatologia')
      allow(repositorios[:medico]).to receive(:all).and_return([medico1])

      verificar_matriculas_duplicadas(%w[ABC123 ábc123 ÁBC123])
    end
  end

  it 'deberia devolver todos los medicos' do
    allow(repositorios[:medico]).to receive(:all)
      .and_return([Medico.new('Michael', 'Jordan', '1', Especialidad.new('Traumatologia', 10, 5))])

    medicos = turnero.medicos
    expect(medicos.first.nombre).to eq('Michael')
  end

  describe 'crear una especialidad' do
    before(:each) do
      allow(repositorios[:especialidad]).to receive(:buscar_por_nombre).and_return(nil)
      allow(repositorios[:especialidad]).to receive(:all).and_return([])
      allow(repositorios[:especialidad]).to receive(:save) do |especialidad|
        especialidad
      end
    end

    def configurar_especialidad_existente(especialidad)
      allow(repositorios[:especialidad]).to receive(:all).and_return([especialidad])
      allow(repositorios[:especialidad]).to receive(:buscar_por_nombre)
        .with(especialidad.nombre).and_return(especialidad)
    end

    def verificar_nombres_duplicados(nombres)
      nombres.each do |nombre|
        expect { turnero.crear_especialidad(nombre, 30, 2) }
          .to raise_error(EspecialidadDuplicadaException)
      end
    end

    it 'deberia crear una especialidad' do
      especialidad = turnero.crear_especialidad('Dermatologia', 10, 5)
      expect(especialidad.nombre).to eq('Dermatologia')
    end

    it 'el nombre de la especialidad debe ser unico - caso basico' do
      especialidad1 = turnero.crear_especialidad('Cardiologia', 10, 5)
      configurar_especialidad_existente(especialidad1)

      expect { turnero.crear_especialidad('Cardiologia', 15, 2) }
        .to raise_error(EspecialidadDuplicadaException)
    end

    it 'el nombre de la especialidad debe ser unico sin importar mayusculas o acentos' do
      especialidad1 = turnero.crear_especialidad('Oftalmologia', 30, 2)
      configurar_especialidad_existente(especialidad1)

      verificar_nombres_duplicados(%w[oftalmologia OFTALMOLOGIA Oftalmología])
    end
  end

  it 'deberia devolver todas las especialidades' do
    especialidades = turnero.especialidades
    expect(especialidades.first.nombre).to eq('Traumatologia')
  end

  def configurar_medicos_mock
    allow(repositorios[:medico]).to receive(:all)
      .and_return([Medico.new('Michael', 'Jordan', '1', Especialidad.new('Traumatologia', 10, 5))])
  end

  it 'deberia devolver los medicos disponibles' do
    configurar_medicos_mock
    medicos_disponibles = turnero.medicos_disponibles

    expect(medicos_disponibles.size).to be <= 7
    expect(medicos_disponibles.first.apellido).to eq('Jordan')
    expect(medicos_disponibles.first.matricula).to eq('1')
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
    before(:each) do
      allow(repositorios[:medico]).to receive(:buscar_por_especialidad)
        .and_return([Medico.new('Medico2', 'Apellido2', 'XYZ123', Especialidad.new('Traumatologia', 10, 5))])
    end

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
      expect(turnero.cancelar_turno(1, usuario.email, true).estado).to eq('Cancelado')
    end

    it 'cancelar turno devuelve un turno ausente si se hace con menos de 24hs de anticipacion' do
      fecha_turno = proveedores[:fecha].ahora + 12 * 60 * 60
      usuario = Usuario.new('usuario@mail.com')
      allow(repositorios[:turnos]).to receive(:buscar_por_id).with(1).and_return(Turno.new('medico', usuario, fecha_turno))
      allow(repositorios[:turnos]).to receive(:save).with(instance_of(Turno))
      expect(turnero.cancelar_turno(1, usuario.email, true).estado).to eq('Ausente')
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

  describe 'Eliminar médico' do
    it 'deberia eliminar medico y sus turnos asociados dado su matricula' do
      medico = instance_double('Medico', 'ABC123')
      allow(repositorios[:medico]).to receive(:buscar_por_matricula).with('ABC123').and_return(medico)
      allow(repositorios[:turnos]).to receive(:eliminar_por_medico).with(medico)

      expect(repositorios[:medico]).to receive(:delete).with(medico)
      turnero.eliminar_medico_por_matricula('ABC123')
    end
  end

  describe 'Modificar especialidad' do
    it 'deberia modificar el nombre y el limite de turnos por usuario de una especialidad' do
      allow(repositorios[:especialidad]).to receive(:save).and_return(Especialidad.new('Traumatologia General', 30, 5))
      allow(repositorios[:especialidad]).to receive(:buscar_por_nombre).and_return(Especialidad.new('Traumatologia', 30, 3))

      especialidad_modificada = turnero.modificar_especialidad('Traumatologia', 'Traumatologia General', 5)

      expect(especialidad_modificada.nombre).to eq('Traumatologia General')
      expect(especialidad_modificada.limite_turnos_por_usuario).to eq(5)
    end
  end
end
