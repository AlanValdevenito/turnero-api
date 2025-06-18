require 'integration_helper'
require_relative '../../dominio/gestores/gestor_especialidades'

describe GestorEspecialidades do
  let(:repositorio_especialidades) do
    instance_double('RepositorioEspecialidades', save: Especialidad.new('Traumatologia General', 30, 5),
                                                 buscar_por_nombre: Especialidad.new('Traumatologia', 30, 3))
  end

  let(:gestor_especialidades) { described_class.new(repositorio_especialidades) }

  describe 'Modificar especialidad' do
    it 'deberia modificar el nombre y el limite de turnos por usuario de una especialidad' do
      especialidad_modificada = gestor_especialidades.modificar_especialidad_por_nombre('Traumatologia', 'Traumatologia General', 5)

      expect(especialidad_modificada.nombre).to eq('Traumatologia General')
      expect(especialidad_modificada.limite_turnos_por_usuario).to eq(5)
    end
  end
end
