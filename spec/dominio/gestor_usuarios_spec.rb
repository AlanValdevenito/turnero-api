require 'integration_helper'
Dir[File.join(__dir__, '../../dominio', '*.rb')].each { |file| require file }

describe GestorUsuarios do
  subject(:gestor_usuarios) { described_class.new(repositorio_usuarios, repositorio_turnos) }

  let(:repositorio_usuarios) { instance_double('RepositorioUsuarios') }
  let(:repositorio_turnos) { instance_double('RepositorioTurnos') }
  let(:email) { 'test@email.com' }
  let(:telegram_id) { 123_456_789 }

  def stub_usuario_no_existente(repositorio_usuarios, email, telegram_id = nil)
    allow(repositorio_usuarios).to receive(:save).with(instance_of(Usuario))
    allow(repositorio_usuarios).to receive(:buscar_por_email).with(email).and_return(nil)
    allow(repositorio_usuarios).to receive(:buscar_por_telegram_id).with(telegram_id).and_return(nil) if telegram_id
  end

  it 'crea un usuario si no existe el email ni el telegram_id' do
    stub_usuario_no_existente(repositorio_usuarios, email, telegram_id)
    usuario = gestor_usuarios.crear_usuario(email, telegram_id)
    expect(usuario.email).to eq(email)
    expect(usuario.telegram_id).to eq(telegram_id)
  end

  it 'lanza error si el email ya existe' do
    allow(repositorio_usuarios).to receive(:buscar_por_email).with(email).and_return(Usuario.new(email, id: 1))
    expect { gestor_usuarios.crear_usuario(email) }.to raise_error(EmailEnUsoException)
  end

  it 'lanza error si el telegram_id ya existe' do
    allow(repositorio_usuarios).to receive(:buscar_por_email).with(email).and_return(nil)
    allow(repositorio_usuarios).to receive(:buscar_por_telegram_id).with(telegram_id).and_return(Usuario.new(email, id: 1, telegram_id:))
    expect { gestor_usuarios.crear_usuario(email, telegram_id) }.to raise_error(TelegramIdEnUsoException)
  end

  it 'lanza error si el email es nil' do
    allow(repositorio_usuarios).to receive(:buscar_por_email).with(nil).and_return(nil)
    expect { gestor_usuarios.crear_usuario(nil) }.to raise_error(EmailObligatorioException)
  end

  it 'lanza error si el email es vacío' do
    allow(repositorio_usuarios).to receive(:buscar_por_email).with('').and_return(nil)
    expect { gestor_usuarios.crear_usuario('') }.to raise_error(EmailObligatorioException)
  end

  it 'devuelve todos los usuarios' do
    usuarios = [Usuario.new(email, id: 1)]
    allow(repositorio_usuarios).to receive(:all).and_return(usuarios)
    expect(gestor_usuarios.usuarios).to eq(usuarios)
  end

  it 'busca usuario por email' do
    usuario = Usuario.new(email, id: 1)
    allow(repositorio_usuarios).to receive(:buscar_por_email).with(email).and_return(usuario)
    expect(gestor_usuarios.buscar_usuario_por_email(email)).to eq(usuario)
  end

  it 'busca usuario por telegram_id' do
    usuario = Usuario.new(email, id: 1, telegram_id:)
    allow(repositorio_usuarios).to receive(:buscar_por_telegram_id).with(telegram_id).and_return(usuario)
    expect(gestor_usuarios.buscar_usuario_por_telegram_id(telegram_id)).to eq(usuario)
  end

  it 'lanza error si no se encuentra usuario por email' do
    allow(repositorio_usuarios).to receive(:buscar_por_email).with(email).and_return(nil)
    expect { gestor_usuarios.buscar_usuario_por_email(email) }.to raise_error(UsuarioNoEncontradoException)
  end

  it 'lanza error si no se encuentra usuario por telegram_id' do
    allow(repositorio_usuarios).to receive(:buscar_por_telegram_id).with(telegram_id).and_return(nil)
    expect { gestor_usuarios.buscar_usuario_por_telegram_id(telegram_id) }.to raise_error(UsuarioNoEncontradoException)
  end

  it 'actualiza un usuario existente' do
    usuario = Usuario.new(email, id: 1, telegram_id:)
    allow(repositorio_usuarios).to receive(:buscar_por_id).with(1).and_return(usuario)
    expect(repositorio_usuarios).to receive(:save).with(usuario)

    gestor_usuarios.actualizar(usuario)
  end
end
