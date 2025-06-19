require_relative './abstract_repository'

class RepositorioUsuarios < AbstractRepository
  self.table_name = :usuarios
  self.model_class = 'Usuario'

  def buscar_por_email(email)
    row = dataset.first(email:)
    load_object(row) unless row.nil?
  end

  def buscar_por_telegram_id(telegram_id)
    row = dataset.first(telegram_id:)
    load_object(row) unless row.nil?
  end

  def buscar_por_id(id)
    row = dataset.first(id:)
    load_object(row) unless row.nil?
  end

  protected

  def load_object(a_hash)
    Usuario.new(
      a_hash[:email],
      id: a_hash[:id],
      telegram_id: a_hash[:telegram_id],
      penalizable: a_hash[:penalizable],
      ultima_penalizacion: a_hash[:ultima_penalizacion]
    )
  end

  def changeset(usuario)
    {
      email: usuario.email,
      telegram_id: usuario.telegram_id,
      penalizable: usuario.penalizable,
      ultima_penalizacion: usuario.ultima_penalizacion
    }
  end
end
