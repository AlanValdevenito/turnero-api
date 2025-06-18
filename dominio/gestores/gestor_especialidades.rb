class GestorEspecialidades
  def initialize(repositorio_especialidades)
    @repositorio_especialidades = repositorio_especialidades
  end

  def modificar_especialidad_por_nombre(nombre, nuevo_nombre, nuevo_limite)
    especialidad = @repositorio_especialidades.buscar_por_nombre(nombre)

    especialidad.nombre = nuevo_nombre
    especialidad.limite_turnos_por_usuario = nuevo_limite

    @repositorio_especialidades.save(especialidad)
  end
end
