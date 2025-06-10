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
                                                                 buscar_por_nombre: Especialidad.new('Traumatologia', 10))
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
      allow(repositorios[:turnos]).to receive(:save).with(turnos[:futuro]).and_return(turnos[:futuro])
      allow(repositorios[:turnos]).to receive(:save).with(turnos[:pasado]).and_return(turnos[:pasado])
    end

    it 'permite cancelar un turno futuro' do
      allow(repositorios[:turnos]).to receive(:buscar_por_id).with(2).and_return(turnos[:futuro])
      allow(proveedores[:hora]).to receive(:ahora).and_return(Time.new(2025, 6, 10, 9, 0, 0))
      expect(turnos[:futuro]).to receive(:estado=).with(ESTADO_CANCELADO)
      result = turnero.modificar_estado_turno(2, ESTADO_CANCELADO)
      expect(result).to eq(turnos[:futuro])
    end

    it 'no permite cancelar un turno pasado' do
      allow(repositorios[:turnos]).to receive(:buscar_por_id).with(3).and_return(turnos[:pasado])
      allow(proveedores[:hora]).to receive(:ahora).and_return(Time.new(2025, 6, 10, 9, 0, 0))
      expect { turnero.modificar_estado_turno(3, ESTADO_CANCELADO) }.to raise_error(EstadoInvalidoException)
    end

    it 'permite marcar como asistido un turno pasado' do
      allow(repositorios[:turnos]).to receive(:buscar_por_id).with(3).and_return(turnos[:pasado])
      allow(proveedores[:hora]).to receive(:ahora).and_return(Time.new(2025, 6, 10, 9, 0, 0))
      expect(turnos[:pasado]).to receive(:estado=).with(ESTADO_ASISTIDO)
      result = turnero.modificar_estado_turno(3, ESTADO_ASISTIDO)
      expect(result).to eq(turnos[:pasado])
    end

    it 'no permite marcar como asistido un turno futuro' do
      allow(repositorios[:turnos]).to receive(:buscar_por_id).with(2).and_return(turnos[:futuro])
      allow(proveedores[:hora]).to receive(:ahora).and_return(Time.new(2025, 1, 1, 9, 0, 0))
      expect { turnero.modificar_estado_turno(2, ESTADO_ASISTIDO) }.to raise_error(EstadoInvalidoException)
    end
  end
end
