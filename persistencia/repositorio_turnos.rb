require 'date'
require_relative './abstract_repository'

class RepositorioTurnos < AbstractRepository
  self.table_name = :turnos
  self.model_class = 'Turno'

  def buscar_por_usuario(usuario)
    load_collection dataset.where(usuario_id: usuario.id)
  end

  def buscar_por_medico(medico)
    load_collection dataset.where(medico_id: medico.id)
  end

  def obtener_turnos_existentes(medico_id, fecha_inicio, fecha_fin)
    dataset
      .where(medico_id:)
      .where { fecha_hora >= fecha_inicio && fecha_hora < fecha_fin }
      .select(:fecha_hora)
      .to_a
  end

  protected

  def load_object(a_hash)
    medico = RepositorioMedicos.new.buscar_por_id(a_hash[:medico_id])
    usuario = RepositorioUsuarios.new.buscar_por_id(a_hash[:usuario_id])
    Turno.new(medico, usuario, a_hash[:fecha_hora], a_hash[:estado], a_hash[:id])
  end

  def changeset(turno)
    {
      medico_id: turno.medico.id,
      usuario_id: turno.usuario.id,
      fecha_hora: turno.fecha_hora,
      estado: turno.estado
    }
  end
end
