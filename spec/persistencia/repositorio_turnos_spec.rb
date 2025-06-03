require 'integration_helper'
require_relative '../../dominio/turno'
require_relative '../../dominio/especialidad'
require_relative '../../dominio/medico'
require_relative '../../dominio/usuario'
require_relative '../../persistencia/repositorio_turnos'
require_relative '../../persistencia/repositorio_medicos'
require_relative '../../persistencia/repositorio_especialidades'
require_relative '../../persistencia/repositorio_usuarios'

describe RepositorioTurnos do
  let(:repositorios) do
    {
      repo_turnos: described_class.new,
      repo_especialidades: RepositorioEspecialidades.new,
      repo_medicos: RepositorioMedicos.new,
      repo_usuarios: RepositorioUsuarios.new
    }
  end

  let(:especialidad) { repositorios[:repo_especialidades].save(Especialidad.new('Cardiología', 20)) }
  let(:medico)       { repositorios[:repo_medicos].save(Medico.new('Ana', 'García', '123456', especialidad)) }
  let(:usuario)      { repositorios[:repo_usuarios].save(Usuario.new('ana@gmail.com')) }

  def crear_turno_para(medico, usuario, fecha_hora)
    turno = Turno.new(medico.id, usuario.id, fecha_hora)
    repositorios[:repo_turnos].save(turno)
    turno
  end

  it 'guarda y asigna id si el turno es nuevo' do
    turno = crear_turno_para(medico, usuario, DateTime.parse('2025-06-05T10:00:00'))
    expect(turno.id).not_to be_nil
  end

  it 'carga correctamente un turno guardado' do
    turno = crear_turno_para(medico, usuario, DateTime.parse('2025-06-10T11:30:00'))

    turno_cargado = repositorios[:repo_turnos].all.find { |t| t.id == turno.id }

    expect(turno_cargado.usuario_id).to eq(usuario.id)
    expect(turno_cargado.medico_id).to eq(medico.id)
    expect(turno_cargado.fecha_hora.to_time).to eq(turno.fecha_hora.to_time)
  end
end
