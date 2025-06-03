class Turno
  attr_reader :created_on, :updated_on
  attr_accessor :id, :medico_id, :usuario_id, :fecha_hora

  def initialize(medico_id, usuario_id, fecha_hora, id = nil)
    @id = id
    @medico_id = medico_id
    @usuario_id = usuario_id
    @fecha_hora = fecha_hora
  end
end
