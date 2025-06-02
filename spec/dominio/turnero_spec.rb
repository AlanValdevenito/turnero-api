require 'integration_helper'
require_relative '../../dominio/turnero'

describe 'Turnero' do
  let(:repositorio) { instance_double('RepositorioUsuarios') }
  let(:turnero)     { Turnero.new(repositorio) }
  let(:email)       { 'test@email.com' }

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
