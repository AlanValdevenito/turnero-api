class Turno
  attr_reader :created_on, :updated_on
  attr_accessor :id, :medico, :usuario, :fecha_hora, :estado

  ESTADO_PENDIENTE = 'Pendiente'.freeze

  def initialize(medico, usuario, fecha_hora, estado = ESTADO_PENDIENTE, id = nil)
    @id = id
    @medico = medico
    @usuario = usuario
    @fecha_hora = fecha_hora
    @estado = estado
  end

  def self.crear(medico, usuario, fecha, hora)
    new(medico, usuario, DateTime.parse("#{fecha} #{hora}"))
  end

  def fecha
    fecha_hora.strftime('%Y-%m-%d')
  end

  def hora
    fecha_hora.strftime('%H:%M')
  end

  def proximas_24hs?(ahora)
    (@fecha_hora.to_time - ahora).abs < 24 * 60 * 60
  end
end
