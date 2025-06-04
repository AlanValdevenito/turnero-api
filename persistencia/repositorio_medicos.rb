require_relative './abstract_repository'

class RepositorioMedicos < AbstractRepository
  self.table_name = :medicos
  self.model_class = 'Medico'

  def buscar_por_matricula(matricula)
    row = dataset.first(matricula:)
    load_object(row) unless row.nil?
  end

  protected

  def load_object(a_hash)
    especialidad = RepositorioEspecialidades.new.buscar_por_id(a_hash[:especialidad_id])
    Medico.new(a_hash[:nombre], a_hash[:apellido], a_hash[:matricula], especialidad)
  end

  def changeset(medico)
    {
      nombre: medico.nombre,
      apellido: medico.apellido,
      matricula: medico.matricula,
      especialidad_id: medico.especialidad.id
    }
  end
end
