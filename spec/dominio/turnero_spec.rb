require 'integration_helper'
require_relative '../../dominio/turnero'
require_relative '../../dominio/medico'

describe Turnero do
  it 'deberia crear un medico' do
    repo_usuarios = instance_double('repositorios_usuarios_dummy')
    repo_medicos = instance_double('repositorios_medicos', save: Medico.new('Michael', 'Jordan', 'Traumatologia', 1))
    turnero = described_class.new(repo_usuarios, repo_medicos)
    medico = turnero.crear_medico('Michael', 'Jordan', 'Traumatologia', 1)
    expect(medico.nombre).to eq('Michael')
  end

  it 'deberia devolver todos los medicos' do
    repo_usuarios = instance_double('repositorios_usuarios_dummy')
    repo_medicos = instance_double('repositorios_medicos', all: [Medico.new('Michael', 'Jordan', 'Traumatologia', 1)])
    turnero = described_class.new(repo_usuarios, repo_medicos)
    medicos = turnero.medicos
    expect(medicos.first.nombre).to eq('Michael')
  end
end
