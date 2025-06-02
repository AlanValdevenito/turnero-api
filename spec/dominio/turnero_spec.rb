require 'integration_helper'
require_relative '../../dominio/turnero'
require_relative '../../dominio/medico'

describe Turnero do
  let(:email)       { 'test@email.com' }
  let(:turnero)     { Turnero.new(repositorio) }
  let(:repositorio) { instance_double('RepositorioUsuarios') }

  it 'deberia crear un medico' do
    repo_usuarios = instance_double('repositorios_usuarios_dummy')
    repo_medicos = instance_double('repositorios_medicos', save: Medico.new('Michael', 'Jordan', 'Traumatologia', 1))
    turnero = described_class.new(repo_usuarios, repo_medicos)
    medico = turnero.crear_medico('Michael', 'Jordan', 'Traumatologia', 1)
    expect(medico.nombre).to eq('Michael')
  end

  it 'deberia devolver error si el email ya existe al crear un usuario' do
    allow(repositorio).to receive(:buscar_por_email).with(email).and_return(Usuario.new(email, 1))

    expect { turnero.crear_usuario(email) }.to raise_error(EmailEnUsoException)
  end

  it 'deberia buscar un usuario por email' do
    usuario_mock = Usuario.new(email, 1)

    allow(repositorio).to receive(:buscar_por_email).with(email).and_return(usuario_mock)

    usuario = turnero.buscar_usuario_por_email(email)
    expect(usuario).to eq(usuario_mock)
  end
end
