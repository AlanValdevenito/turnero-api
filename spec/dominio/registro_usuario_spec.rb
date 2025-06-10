require 'integration_helper'
Dir[File.join(__dir__, '../../dominio', '*.rb')].each { |file| require file }

describe RegistroUsuario do
  subject(:registro) { described_class.new(repositorio) }

  let(:repositorio) { instance_double('RepositorioUsuarios') }
  let(:email) { 'test@email.com' }
  let(:telegram_id) { 123_456_789 }

  def stub_usuario_no_existente(repositorio, email, telegram_id = nil)
    allow(repositorio).to receive(:save).with(instance_of(Usuario))
    allow(repositorio).to receive(:buscar_por_email).with(email).and_return(nil)
    allow(repositorio).to receive(:buscar_por_telegram_id).with(telegram_id).and_return(nil) if telegram_id
  end

  it 'crea un usuario si no existe el email ni el telegram_id' do
    stub_usuario_no_existente(repositorio, email, telegram_id)
    usuario = registro.crear_usuario(email, telegram_id)
    expect(usuario.email).to eq(email)
    expect(usuario.telegram_id).to eq(telegram_id)
  end

  it 'lanza error si el email ya existe' do
    allow(repositorio).to receive(:buscar_por_email).with(email).and_return(Usuario.new(email, 1))
    expect { registro.crear_usuario(email) }.to raise_error(EmailEnUsoException)
  end

  it 'lanza error si el telegram_id ya existe' do
    allow(repositorio).to receive(:buscar_por_email).with(email).and_return(nil)
    allow(repositorio).to receive(:buscar_por_telegram_id).with(telegram_id).and_return(Usuario.new(email, 1, telegram_id))
    expect { registro.crear_usuario(email, telegram_id) }.to raise_error(TelegramIdEnUsoException)
  end

  it 'lanza error si el email es nil' do
    allow(repositorio).to receive(:buscar_por_email).with(nil).and_return(nil)
    expect { registro.crear_usuario(nil) }.to raise_error(EmailObligatorioException)
  end

  it 'lanza error si el email es vacío' do
    allow(repositorio).to receive(:buscar_por_email).with('').and_return(nil)
    expect { registro.crear_usuario('') }.to raise_error(EmailObligatorioException)
  end

  it 'devuelve todos los usuarios' do
    usuarios = [Usuario.new(email, 1)]
    allow(repositorio).to receive(:all).and_return(usuarios)
    expect(registro.usuarios).to eq(usuarios)
  end

  it 'busca usuario por email' do
    usuario = Usuario.new(email, 1)
    allow(repositorio).to receive(:buscar_por_email).with(email).and_return(usuario)
    expect(registro.buscar_usuario_por_email(email)).to eq(usuario)
  end

  it 'busca usuario por telegram_id' do
    usuario = Usuario.new(email, 1, telegram_id)
    allow(repositorio).to receive(:buscar_por_telegram_id).with(telegram_id).and_return(usuario)
    expect(registro.buscar_usuario_por_telegram_id(telegram_id)).to eq(usuario)
  end
end
