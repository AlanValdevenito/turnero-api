class Especialidad
  attr_reader :created_on, :updated_on
  attr_accessor :id, :nombre, :duracion_de_turnos, :limite_turnos_por_usuario

  def initialize(nombre, duracion_de_turnos, limite_turnos_por_usuario, id = nil)
    @id = id
    @nombre = nombre
    @duracion_de_turnos = duracion_de_turnos
    @limite_turnos_por_usuario = limite_turnos_por_usuario
  end
end
