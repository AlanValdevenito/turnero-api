require 'integration_helper'
require_relative '../../dominio/medico'
require_relative '../../persistencia/repositorio_medicos'

describe RepositorioMedicos do
  it 'deberia guardar y asignar id si el medico es nuevo' do
    especialidad = Especialidad.new('Traumatologia', 10, 1)
    medico = Medico.new('Michael', 'Jordan', '112324', especialidad)
    described_class.new.save(medico)
    expect(medico.id).not_to be_nil
  end

  it 'deberia cargar los medicos con especialidad' do
    especialidad = RepositorioEspecialidades.new.save(Especialidad.new('Traumatologia', 10))
    medico = Medico.new('Michael', 'Jordan', '112324', especialidad)
    described_class.new.save(medico)
    medico_encontrado = described_class.new.all.first
    expect(medico_encontrado.especialidad.nombre).to eq(especialidad.nombre)
  end

  it 'deberia buscar especialidad por matricula' do
    especialidad = RepositorioEspecialidades.new.save(Especialidad.new('Traumatologia', 10))
    medico = Medico.new('Michael', 'Jordan', '112324', especialidad)
    described_class.new.save(medico)
    medico_encontrado = described_class.new.buscar_por_matricula(medico.matricula)
    expect(medico_encontrado.nombre).to eq(medico.nombre)
  end
end
