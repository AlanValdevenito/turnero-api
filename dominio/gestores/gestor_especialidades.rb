class GestorEspecialidades
  def initialize(repositorio_especialidades)
    @repositorio_especialidades = repositorio_especialidades
  end

  def modificar_especialidad_por_nombre(nombre, nuevo_nombre, nuevo_limite)
    raise LimiteDeTurnosNoEnteroException unless nuevo_limite.is_a?(Integer)
    raise LimiteDeTurnosNoPositivoException unless nuevo_limite > 0

    especialidad = @repositorio_especialidades.buscar_por_nombre(nombre)
    raise EspecialidadNoEncontradaException if especialidad.nil?

    especialidad.nombre = nuevo_nombre
    especialidad.limite_turnos_por_usuario = nuevo_limite

    @repositorio_especialidades.save(especialidad)
  end

  def eliminar_especialidad_por_nombre(nombre)
    especialidad = @repositorio_especialidades.buscar_por_nombre(nombre)
    @repositorio_especialidades.delete(especialidad)
  end
end
