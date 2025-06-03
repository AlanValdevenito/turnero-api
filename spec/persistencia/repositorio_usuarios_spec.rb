require 'integration_helper'
require_relative '../../dominio/usuario'
require_relative '../../persistencia/repositorio_usuarios'

describe RepositorioUsuarios do
  it 'deberia guardar y asignar id si el usuario es nuevo' do
    juan = Usuario.new('juan@test.com', nil, 12_345)
    described_class.new.save(juan)
    expect(juan.id).not_to be_nil
    expect(juan.telegram_id).to eq(12_345)
  end

  it 'deberia recuperar todos' do
    repositorio = described_class.new
    cantidad_de_usuarios_iniciales = repositorio.all.size
    juan = Usuario.new('juan@test.com', nil, 54_321)
    repositorio.save(juan)
    expect(repositorio.all.size).to be(cantidad_de_usuarios_iniciales + 1)
  end

  it 'deberia buscar por email' do
    repositorio = described_class.new
    juan = Usuario.new('juan@test.com', nil, 11_111)
    repositorio.save(juan)
    usuario_recuperado = repositorio.buscar_por_email('juan@test.com')
    expect(usuario_recuperado).to have_attributes(email: 'juan@test.com', id: juan.id, telegram_id: 11_111)
  end

  it 'deberia buscar por telegram_id' do
    repositorio = described_class.new
    juan = Usuario.new('juan@test.com', nil, 22_222)
    repositorio.save(juan)
    usuario_recuperado = repositorio.buscar_por_telegram_id(22_222)
    expect(usuario_recuperado).to have_attributes(email: 'juan@test.com', telegram_id: 22_222)
  end
end
