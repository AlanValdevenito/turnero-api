require 'integration_helper'
require_relative '../../dominio/medico'
require_relative '../../persistencia/repositorio_medicos'

describe RepositorioMedicos do
  it 'deberia guardar y asignar id si el medico es nuevo' do
    especialidad = Especialidad.new('Traumatologia', 10, 5, 1)
    medico = Medico.new('Michael', 'Jordan', '112324', especialidad)
    described_class.new.save(medico)
    expect(medico.id).not_to be_nil
  end

  it 'deberia cargar los medicos con especialidad' do
    especialidad = RepositorioEspecialidades.new.save(Especialidad.new('Traumatologia', 10, 5))
    medico = Medico.new('Michael', 'Jordan', '112324', especialidad)
    described_class.new.save(medico)
    medico_encontrado = described_class.new.all.first
    expect(medico_encontrado.especialidad.nombre).to eq(especialidad.nombre)
  end

  it 'deberia buscar medico por matricula' do
    especialidad = RepositorioEspecialidades.new.save(Especialidad.new('Traumatologia', 10, 5))
    medico = Medico.new('Michael', 'Jordan', '112324', especialidad)
    described_class.new.save(medico)
    medico_encontrado = described_class.new.buscar_por_matricula(medico.matricula)
    expect(medico_encontrado.nombre).to eq(medico.nombre)
  end

  it 'deberia buscar medico por id' do
    repositorio = described_class.new
    medico = Medico.new('Juan', 'Perez', 'ABC123', Especialidad.new('Traumatologia', 10, 5, 1))
    repositorio.save(medico)
    recuperado = repositorio.buscar_por_id(medico.id)
    expect(recuperado.matricula).to eq('ABC123')
  end

  it 'deberia buscar medicos por especialidad' do
    especialidad = RepositorioEspecialidades.new.save(Especialidad.new('Traumatologia', 10, 5))
    medico = Medico.new('Juan', 'Perez', 'ABC123', especialidad)
    described_class.new.save(medico)
    recuperado = described_class.new.buscar_por_especialidad(especialidad)
    expect(recuperado.first.especialidad.nombre).to eq('Traumatologia')
  end
end
