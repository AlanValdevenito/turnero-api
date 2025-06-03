require_relative './abstract_repository'

class RepositorioEspecialidades < AbstractRepository
  self.table_name = :especialidades
  self.model_class = 'Especialidad'

  protected

  def load_object(a_hash)
    Especialidad.new(a_hash[:nombre], a_hash[:duracion_de_turnos])
  end

  def changeset(especialidad)
    {
      nombre: especialidad.nombre,
      duracion_de_turnos: especialidad.duracion_de_turnos
    }
  end
end
