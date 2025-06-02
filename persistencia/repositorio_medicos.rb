require_relative './abstract_repository'

class RepositorioMedicos < AbstractRepository
  self.table_name = :medicos
  self.model_class = 'Medico'

  protected

  def load_object(a_hash)
    Medico.new(a_hash[:nombre], a_hash[:apellido], a_hash[:matricula], a_hash[:especialidad])
  end

  def changeset(medico)
    {
      nombre: medico.nombre,
      apellido: medico.apellido,
      matricula: medico.matricula,
      especialidad_id: medico.especialidad
    }
  end
end
