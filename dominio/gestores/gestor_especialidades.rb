require_relative '../helpers'
class GestorEspecialidades
  def initialize(repositorio_especialidades)
    @repositorio_especialidades = repositorio_especialidades
  end

  def modificar_especialidad_por_nombre(nombre, nuevo_nombre, nuevo_limite)
    raise LimiteDeTurnosNoEnteroException unless nuevo_limite.is_a?(Integer)
    raise LimiteDeTurnosNoPositivoException unless nuevo_limite > 0

    nombre_normalizado = normalizar_texto(nombre).capitalize
    especialidad = @repositorio_especialidades.buscar_por_nombre(nombre_normalizado)
    raise EspecialidadNoEncontradaException if especialidad.nil?

    nuevo_nombre_normalizado = normalizar_texto(nuevo_nombre).capitalize
    especialidad.nombre = nuevo_nombre_normalizado
    especialidad.limite_turnos_por_usuario = nuevo_limite

    @repositorio_especialidades.save(especialidad)
  end

  def eliminar_especialidad_por_nombre(nombre)
    nombre_normalizado = normalizar_texto(nombre).capitalize
    especialidad = @repositorio_especialidades.buscar_por_nombre(nombre_normalizado)
    @repositorio_especialidades.delete(especialidad)
  end
end
