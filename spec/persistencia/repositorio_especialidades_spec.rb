require 'integration_helper'
require_relative '../../dominio/especialidad'
require_relative '../../persistencia/repositorio_especialidades'

describe RepositorioEspecialidades do
  it 'deberia guardar y asignar id si la especialidad es nueva' do
    especialidad = Especialidad.new('Traumatologia', 10)
    described_class.new.save(especialidad)
    expect(especialidad.id).not_to be_nil
  end
end
