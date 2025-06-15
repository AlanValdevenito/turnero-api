require 'integration_helper'
require_relative '../../dominio/usuario'
require_relative '../../persistencia/repositorio_usuarios'

describe RepositorioUsuarios do
  it 'deberia guardar y asignar id si el usuario es nuevo' do
    juan = Usuario.new('juan@test.com', id: nil, telegram_id: 12_345)
    described_class.new.save(juan)
    expect(juan.id).not_to be_nil
    expect(juan.telegram_id).to eq(12_345)
  end

  it 'deberia recuperar todos' do
    repositorio = described_class.new
    cantidad_de_usuarios_iniciales = repositorio.all.size
    juan = Usuario.new('juan@test.com', id: nil, telegram_id: 54_321)
    repositorio.save(juan)
    expect(repositorio.all.size).to be(cantidad_de_usuarios_iniciales + 1)
  end

  it 'deberia buscar por email' do
    repositorio = described_class.new
    juan = Usuario.new('juan@test.com', id: nil, telegram_id: 11_111)
    repositorio.save(juan)
    usuario_recuperado = repositorio.buscar_por_email('juan@test.com')
    expect(usuario_recuperado).to have_attributes(email: 'juan@test.com', id: juan.id, telegram_id: 11_111)
  end

  it 'deberia buscar por telegram_id' do
    repositorio = described_class.new
    juan = Usuario.new('juan@test.com', id: nil, telegram_id: 22_222)
    repositorio.save(juan)
    usuario_recuperado = repositorio.buscar_por_telegram_id(22_222)
    expect(usuario_recuperado).to have_attributes(email: 'juan@test.com', telegram_id: 22_222)
  end

  it 'deberia buscar por id' do
    repositorio = described_class.new
    usuario = Usuario.new('juan@mail.com')
    repositorio.save(usuario)
    recuperado = repositorio.buscar_por_id(usuario.id)
    expect(recuperado.email).to eq('juan@mail.com')
  end

  def crear_y_recuperar_usuario(email, telegram_id: nil, penalizable: true, ultima_penalizacion: nil)
    usuario = Usuario.new(email, telegram_id:, penalizable:, ultima_penalizacion:)
    repositorio = described_class.new
    repositorio.save(usuario)
    repositorio.buscar_por_email(email)
  end

  it 'deberia guardar y recuperar penalizable y ultima_penalizacion' do
    penalizacion = Time.now
    recuperado = crear_y_recuperar_usuario('test@correo.com', telegram_id: 123, penalizable: false, ultima_penalizacion: penalizacion)
    expect(recuperado.penalizable).to eq(false)
    expect(recuperado.ultima_penalizacion.to_i).to eq(penalizacion.to_i)
  end

  it 'deberia tener penalizable en true y ultima_penalizacion en nil por defecto' do
    recuperado = crear_y_recuperar_usuario('default@correo.com', telegram_id: 456)
    expect(recuperado.penalizable).to eq(true)
    expect(recuperado.ultima_penalizacion).to be_nil
  end
end
