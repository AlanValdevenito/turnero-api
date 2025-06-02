class Medico
  attr_reader :created_on, :updated_on
  attr_accessor :id, :nombre, :apellido, :matricula, :especialidad

  def initialize(nombre, apellido, matricula, especialidad, id = nil)
    @id = id
    @nombre = nombre
    @apellido = apellido
    @matricula = matricula
    @especialidad = especialidad
  end
end
