require_relative './abstract_repository'

class RepositorioTurnos < AbstractRepository
  self.table_name = :turnos
  self.model_class = 'Turno'

  protected

  def load_object(a_hash)
    Turno.new(
      a_hash[:medico_id],
      a_hash[:usuario_id],
      a_hash[:fecha_hora],
      a_hash[:id]
    )
  end

  def changeset(turno)
    {
      medico_id: turno.medico_id,
      usuario_id: turno.usuario_id,
      fecha_hora: turno.fecha_hora
    }
  end
end
