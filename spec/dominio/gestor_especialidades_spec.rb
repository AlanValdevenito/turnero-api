require 'integration_helper'
require_relative '../../dominio/gestores/gestor_especialidades'

describe GestorEspecialidades do
  let(:gestor_especialidades) { described_class.new(repositorios[:especialidades], repositorios[:medicos], repositorios[:turnos]) }

  let(:doubles) do
    {
      especialidad: instance_double('Especialidad', nombre: 'Traumatologia', id: 1),
      medico: instance_double('Medico', matricula: 'ABC123', id: 1),
      medico2: instance_double('Medico', matricula: 'ABC000', id: 2),
      turno: instance_double('Turno', id: 1)
    }
  end

  let(:repositorios) do
    {
      especialidades: instance_double('RepositorioEspecialidades', save: Especialidad.new('Traumatologia General', 30, 5), delete: nil),
      medicos: instance_double('RepositorioMedicos', save: doubles[:medico], delete: nil),
      turnos: instance_double('RepositorioTurnos', save: doubles[:turno], delete: nil)
    }
  end

  describe 'Modificar especialidad' do
    it 'deberia modificar el nombre y el limite de turnos por usuario de una especialidad' do
      allow(repositorios[:especialidades]).to receive(:buscar_por_nombre).and_return(Especialidad.new('Traumatologia', 30, 3))
      especialidad_modificada = gestor_especialidades.modificar_especialidad_por_nombre('Traumatologia', 'Traumatologia General', 5)

      expect(especialidad_modificada.nombre).to eq('Traumatologia General')
      expect(especialidad_modificada.limite_turnos_por_usuario).to eq(5)
    end

    it 'deberia devolver error si se intenta modificar el nombre y el limite de turnos por usuario de una especialidad que no existe' do
      allow(repositorios[:especialidades]).to receive(:buscar_por_nombre).and_return(nil)
      expect { gestor_especialidades.modificar_especialidad_por_nombre('Pediatria', 'Pediatria General', 10) }.to raise_error(EspecialidadNoEncontradaException)
    end

    it 'deberia devolver error si se intenta modificar una especialidad con un limite de turnos por usuario negativo' do
      expect { gestor_especialidades.modificar_especialidad_por_nombre('Pediatria', 'Pediatria General', -5) }.to raise_error(LimiteDeTurnosNoPositivoException)
    end

    it 'deberia devolver error si se intenta modificar una especialidad con un limite de turnos por usuario no entero' do
      expect { gestor_especialidades.modificar_especialidad_por_nombre('Pediatria', 'Pediatria General', '5') }.to raise_error(LimiteDeTurnosNoEnteroException)
    end

    it 'deberia eliminar a la especialidad cuando existe' do
      allow(repositorios[:medicos]).to receive(:buscar_por_especialidad).with(doubles[:especialidad]).and_return([])
      allow(repositorios[:especialidades]).to receive(:buscar_por_nombre).with('Traumatologia').and_return(doubles[:especialidad])
      expect(repositorios[:especialidades]).to receive(:delete).with(doubles[:especialidad])
      gestor_especialidades.eliminar_especialidad_por_nombre('Traumatologia')
    end
  end

  describe 'eliminar especialidad' do
    it 'deberia eliminar los turnos y medicos de la especialidad en cascada' do
      allow(repositorios[:medicos]).to receive(:buscar_por_especialidad).with(doubles[:especialidad]).and_return([doubles[:medico], doubles[:medico2]])
      allow(repositorios[:especialidades]).to receive(:buscar_por_nombre).with('Traumatologia').and_return(doubles[:especialidad])
      allow(repositorios[:turnos]).to receive(:buscar_por_medico)
      allow(repositorios[:turnos]).to receive(:eliminar_por_medico)
      gestor_especialidades.eliminar_especialidad_por_nombre('Traumatologia')
    end

    it 'deberia lanzar excepcion si no se encuentra especialidad' do
      allow(repositorios[:especialidades]).to receive(:buscar_por_nombre).with('Inexistente').and_return(nil)
      expect { gestor_especialidades.eliminar_especialidad_por_nombre('Inexistente') }.to raise_error(EspecialidadNoEncontradaException)
    end
  end
end
