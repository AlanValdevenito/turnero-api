class ProveedorFecha
  def initialize(huso_horario = '-03:00')
    @huso_horario = huso_horario
    @fecha_hora_mock = nil
  end

  # Devuelve la hora actual en UTC, o la hora mockeada si fue seteada.
  def ahora
    @fecha_hora_mock || Time.now.utc
  end

  # Devuelve la fecha de hoy en UTC, o la fecha mockeada si está definida.
  def hoy
    ahora.to_date
  end

  # Convierte un instante UTC a la hora local configurada
  def cambiar_a_huso_horario_local(time_utc)
    time_utc.to_time.getlocal(@huso_horario)
  end

  # Construye una hora en local y la convierte a UTC
  def construir_hora_desde_local(anio, mes, dia, hora, min)
    local = Time.new(anio, mes, dia, hora, min, 0, @huso_horario)
    local.utc
  end

  # Construye una hora directamente en UTC
  def construir_hora_utc(anio, mes, dia, hora, min)
    Time.utc(anio, mes, dia, hora, min, 0)
  end

  # Setea una fecha y hora mockeada (Time)
  def setear_fecha_mock(fecha_hora_mock)
    @fecha_hora_mock = fecha_hora_mock
  end

  # Cancela el mock de fecha y hora
  def cancelar_mock
    @fecha_hora_mock = nil
  end

  attr_reader :huso_horario
end