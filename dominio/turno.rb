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

  def cambiar_fecha(nueva_fecha)
    nueva_fecha_str = nueva_fecha.is_a?(String) ? nueva_fecha : nueva_fecha.strftime('%Y-%m-%d')
    nueva_fecha_hora = DateTime.parse("#{nueva_fecha_str} #{hora}")
    @fecha_hora = nueva_fecha_hora
  end

  def cambiar_hora(nueva_hora)
    nueva_hora_str = nueva_hora.is_a?(String) ? nueva_hora : nueva_hora.strftime('%H:%M')
    nueva_fecha_hora = DateTime.parse("#{fecha} #{nueva_hora_str}")
    @fecha_hora = nueva_fecha_hora
  end

  def cambiar_fecha_hora(fecha_hora)
    raise ArgumentError, 'Fecha y hora deben ser un objeto DateTime' unless fecha_hora.is_a?(DateTime)

    @fecha_hora = fecha_hora
  end

  def proximas_24hs?(ahora)
    (@fecha_hora.to_time - ahora).abs < 24 * 60 * 60
  end
end
