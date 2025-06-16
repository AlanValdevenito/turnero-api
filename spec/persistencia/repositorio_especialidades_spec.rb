require 'integration_helper'
require_relative '../../dominio/especialidad'
require_relative '../../persistencia/repositorio_especialidades'

describe RepositorioEspecialidades do
  it 'deberia guardar y asignar id si la especialidad es nueva' do
    especialidad = Especialidad.new('Traumatologia', 10, 5)
    described_class.new.save(especialidad)
    expect(especialidad.id).not_to be_nil
  end

  it 'deberia buscar especialidad por nombre' do
    especialidad = Especialidad.new('Traumatologia', 10, 5)
    described_class.new.save(especialidad)
    especialidad_encontrada = described_class.new.buscar_por_nombre('Traumatologia')
    expect(especialidad_encontrada.nombre).to eq(especialidad.nombre)
    expect(especialidad_encontrada.duracion_de_turnos).to eq(especialidad.duracion_de_turnos)
  end

  it 'deberia buscar especialidad por id' do
    especialidad = Especialidad.new('Traumatologia', 10, 5)
    described_class.new.save(especialidad)
    especialidad_encontrada = described_class.new.buscar_por_id(especialidad.id)
    expect(especialidad_encontrada.nombre).to eq(especialidad.nombre)
    expect(especialidad_encontrada.duracion_de_turnos).to eq(especialidad.duracion_de_turnos)
  end
end
