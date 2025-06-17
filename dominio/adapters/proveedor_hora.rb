class ProveedorHora
  def initialize(huso_horario = '-03:00')
    @huso_horario = huso_horario
    @hora_mock = nil
  end

  # Devuelve la hora actual en UTC, o la hora mockeada si fue seteada.
  #
  # @return [Time] La hora actual en UTC, o la hora mockeada si está definida.
  #
  # Ejemplo:
  #   ahora # => 2025-06-13 18:30:00 UTC
  def ahora
    @hora_mock || Time.now.utc
  end

  # @param [Time, DateTime] time_utc - un instante en UTC
  # @return [Time] El mismo instante convertido a la hora local configurada
  #
  # Ejemplo:
  #   cambiar_a_huso_horario_local(Time.utc(2025, 6, 13, 18, 0))
  #   => 2025-06-13 15:00:00 -0300
  def cambiar_a_huso_horario_local(time_utc)
    time_utc.to_time.getlocal(@huso_horario)
  end

  # @param [Integer] anio
  # @param [Integer] mes
  # @param [Integer] dia
  # @param [Integer] hora
  # @param [Integer] min
  # @return [Time] La hora construida en local convertida a UTC
  #
  # Ejemplo: construir_hora_desde_local(2025, 6, 14, 8, 0) => 2025-06-14 11:00:00 UTC
  def construir_hora_desde_local(anio, mes, dia, hora, min)
    local = Time.new(anio, mes, dia, hora, min, 0, @huso_horario)
    local.utc
  end

  # @param [Integer] anio
  # @param [Integer] mes
  # @param [Integer] dia
  # @param [Integer] hora
  # @param [Integer] min
  # @return [Time] La hora construida directamente en UTC
  #
  # Ejemplo: construir_hora_utc(2025, 6, 14, 11, 0) => 2025-06-14 11:00:00 UTC
  def construir_hora_utc(anio, mes, dia, hora, min)
    Time.utc(anio, mes, dia, hora, min, 0)
  end

  # @return [String] el huso horario actual como string ("-03:00")
  attr_reader :huso_horario

  def setear_hora_mock(hora_mock)
    @hora_mock = hora_mock
  end
end
