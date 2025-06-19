require_relative './abstract_repository'

class RepositorioEspecialidades < AbstractRepository
  self.table_name = :especialidades
  self.model_class = 'Especialidad'

  def buscar_por_nombre(nombre)
    row = dataset.first(nombre:)
    load_object(row) unless row.nil?
  end

  def buscar_por_id(id)
    row = dataset.first(id:)
    load_object(row) unless row.nil?
  end

  protected

  def load_object(a_hash)
    Especialidad.new(a_hash[:nombre], a_hash[:duracion_de_turnos], a_hash[:limite_turnos_por_usuario], a_hash[:id])
  end

  def changeset(especialidad)
    {
      nombre: especialidad.nombre,
      duracion_de_turnos: especialidad.duracion_de_turnos,
      limite_turnos_por_usuario: especialidad.limite_turnos_por_usuario
    }
  end
end
