class Turno
  attr_reader :created_on, :updated_on
  attr_accessor :id, :medico, :usuario, :fecha_hora, :estado

  def initialize(medico, usuario, fecha_hora, id = nil)
    @id = id
    @medico = medico
    @usuario = usuario
    @fecha_hora = fecha_hora
  end
end
