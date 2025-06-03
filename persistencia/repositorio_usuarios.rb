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

  protected

  def load_object(a_hash)
    Usuario.new(a_hash[:email], a_hash[:id], a_hash[:telegram_id])
  end

  def changeset(usuario)
    {
      email: usuario.email,
      telegram_id: usuario.telegram_id
    }
  end
end
