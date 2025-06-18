require 'integration_helper'
require_relative '../../dominio/gestores/gestor_especialidades'

describe GestorEspecialidades do
  let(:repositorio_especialidades) { instance_double('RepositorioEspecialidades', save: Especialidad.new('Traumatologia General', 30, 5)) }

  let(:gestor_especialidades) { described_class.new(repositorio_especialidades) }

  describe 'Modificar especialidad' do
    it 'deberia modificar el nombre y el limite de turnos por usuario de una especialidad' do
      allow(repositorio_especialidades).to receive(:buscar_por_nombre).and_return(Especialidad.new('Traumatologia', 30, 3))
      especialidad_modificada = gestor_especialidades.modificar_especialidad_por_nombre('Traumatologia', 'Traumatologia General', 5)

      expect(especialidad_modificada.nombre).to eq('Traumatologia General')
      expect(especialidad_modificada.limite_turnos_por_usuario).to eq(5)
    end

    it 'deberia devolver error si se intenta modificar el nombre y el limite de turnos por usuario de una especialidad que no existe' do
      allow(repositorio_especialidades).to receive(:buscar_por_nombre).and_return(nil)
      expect { gestor_especialidades.modificar_especialidad_por_nombre('Pediatria', 'Pediatria General', 10) }.to raise_error(EspecialidadNoEncontradaException)
    end

    it 'deberia devolver error si se intenta modificar una especialidad con un limite de turnos por usuario negativo' do
      expect { gestor_especialidades.modificar_especialidad_por_nombre('Pediatria', 'Pediatria General', -5) }.to raise_error(LimiteDeTurnosNoPositivoException)
    end
  end
end
