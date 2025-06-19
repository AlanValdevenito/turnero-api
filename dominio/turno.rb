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

  def se_superpone_con?(otro_turno)
    inicio_otra_fecha = construir_inicio_turno(otro_turno)
    fin_otra_fecha = inicio_otra_fecha + duracion_en_segundos(otro_turno)

    inicio_actual = @fecha_hora.to_time
    fin_actual = inicio_actual + duracion_en_segundos(self)

    inicio_actual < fin_otra_fecha && inicio_otra_fecha < fin_actual
  end

  private

  def construir_inicio_turno(turno)
    hora = Time.parse(turno.hora)
    Time.new(@fecha_hora.year, @fecha_hora.month, @fecha_hora.day, hora.hour, hora.min)
  end

  def duracion_en_segundos(turno)
    turno.medico.especialidad.duracion_de_turnos * 60
  end
end
