class Especialidad
  attr_reader :created_on, :updated_on
  attr_accessor :id, :nombre, :duracion_de_turnos

  def initialize(nombre, duracion_de_turnos, id = nil)
    @id = id
    @nombre = nombre
    @duracion_de_turnos = duracion_de_turnos
  end
end
