require 'integration_helper'
Dir[File.join(__dir__, '../../dominio', '*.rb')].each { |file| require file }
require_relative '../../dominio/excepciones/estado_invalido_exception'

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
      turnos: instance_double('RepositorioTurnos')
    }
  end

  let(:proveedores) do
    {
      dia: instance_double('ProveedorDia', hoy: Date.parse('2025-06-16')),
      feriados: instance_double('ProveedorFeriadosDummy', feriados: [{ "dia": 16, "mes": 6 }]),
      hora: instance_double('ProveedorHora', ahora: Time.new(2025, 6, 16, 10, 0, 0))
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

  describe 'Historial de turnos' do
    it 'deberia lanzar excepcion NoHayHistorialTurnosException si el paciente nunca reservo turnos' do
      usuario = instance_double('Usuario', email: 'pepe@mail.com')
      allow(repositorios[:usuario]).to receive(:buscar_por_email).with('pepe@mail.com').and_return(usuario)
      allow(repositorios[:turnos]).to receive(:buscar_por_usuario).with(usuario).and_return([])
      expect { turnero.historial_turnos_paciente('pepe@mail.com') }.to raise_error(NoHayHistorialTurnosException)
    end
  end
end
