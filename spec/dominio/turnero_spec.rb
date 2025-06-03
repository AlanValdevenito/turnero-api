require 'integration_helper'
require_relative '../../dominio/turnero'
require_relative '../../dominio/medico'

describe Turnero do
  let(:email) { 'test@email.com' }
  let(:repositorio_usuario) { instance_double('RepositorioUsuarios') }
  let(:repositorio_medico) { instance_double('repositorios_medicos', save: Medico.new('Michael', 'Jordan', 1, 'Traumatologia'), all: [Medico.new('Michael', 'Jordan', 1, 'Traumatologia')]) }
  let(:repositorio_especialidades) { instance_double('RepositorioEspecialidades', save: Especialidad.new('Traumatologia', 10), all: [Especialidad.new('Traumatologia', 10)]) }
  let(:turnero) { described_class.new(repositorio_usuario, repositorio_medico, repositorio_especialidades) }

  def stub_usuario_no_existente(repositorio, email, telegram_id = nil)
    allow(repositorio).to receive(:save).with(instance_of(Usuario))
    allow(repositorio).to receive(:buscar_por_email).with(email).and_return(nil)
    allow(repositorio).to receive(:buscar_por_telegram_id).with(telegram_id).and_return(nil) if telegram_id
  end

  it 'deberia crear un medico' do
    medico = turnero.crear_medico('Michael', 'Jordan', 'Traumatologia', 1)
    expect(medico.nombre).to eq('Michael')
  end

  it 'deberia devolver error si el email ya existe al crear un usuario' do
    allow(repositorio_usuario).to receive(:buscar_por_email).with(email).and_return(Usuario.new(email, 1))

    expect { turnero.crear_usuario(email) }.to raise_error(EmailEnUsoException)
  end

  it 'deberia buscar un usuario por email' do
    usuario_mock = Usuario.new(email, 1)

    allow(repositorio_usuario).to receive(:buscar_por_email).with(email).and_return(usuario_mock)

    usuario = turnero.buscar_usuario_por_email(email)
    expect(usuario).to eq(usuario_mock)
  end

  it 'deberia devolver todos los medicos' do
    medicos = turnero.medicos
    expect(medicos.first.nombre).to eq('Michael')
  end

  it 'deberia crear una especialidad' do
    especialidad = turnero.crear_especialidad('Traumatologia', 10)
    expect(especialidad.nombre).to eq('Traumatologia')
  end

  it 'deberia devolver todas las especialidades' do
    especialidades = turnero.especialidades
    expect(especialidades.first.nombre).to eq('Traumatologia')
  end

  it 'deberia crear un usuario' do
    stub_usuario_no_existente(repositorio_usuario, email, 123_456_789)
    created_user = turnero.crear_usuario(email, 123_456_789)
    expect(created_user.email).to eq(email)
    expect(created_user.telegram_id).to eq(123_456_789)
  end

  it 'deberia devolver error si el telegram_id ya existe al crear un usuario' do
    allow(repositorio_usuario).to receive(:buscar_por_email).with(email).and_return(nil)
    allow(repositorio_usuario).to receive(:buscar_por_telegram_id).with(123_456_789).and_return(Usuario.new(email, 1, 123_456_789))

    expect { turnero.crear_usuario(email, 123_456_789) }.to raise_error(TelegramIdEnUsoException)
  end
end
