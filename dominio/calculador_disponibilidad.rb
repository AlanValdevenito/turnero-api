class CalculadorDeDisponibilidad
  attr_reader :proveedor_fecha

  def initialize(proveedor_fecha, proveedor_feriados)
    @proveedor_fecha = proveedor_fecha
    @proveedor_feriados = proveedor_feriados
  end

  def turnos_disponibles(duracion_turno, turnos_existentes, cantidad, fecha_inicio, fecha_fin)
    tiempos_ocupados = Set.new(turnos_existentes.map { |t| t[:fecha_hora].to_i })

    turnos_disponibles = []
    feriados = @proveedor_feriados.feriados(fecha_inicio.year)
    (fecha_inicio...fecha_fin).each do |fecha|
      next unless dia_laboral?(fecha, feriados)

      turnos_disponibles.concat(turnos_para_dia(fecha, duracion_turno, tiempos_ocupados))
    end

    turnos_disponibles.first(cantidad)
  end

  # Calcula los turnos disponibles para un día, respetando la jornada laboral, la duración de los turnos,
  # y los horarios ya ocupados.
  #
  # @param [Date] fecha - Día para el cual se desean calcular los turnos (ej. Date.new(2025, 6, 14))
  # @param [Integer] duracion - Duración de cada turno en minutos (ej. 30)
  # @param [Set<Integer>] tiempos_ocupados - Conjunto de timestamps UNIX (segundos desde epoch) de turnos ya ocupados
  #
  # @return [Array<DateTime>] Lista de turnos disponibles para ese día, expresados en UTC
  #
  # Ejemplo de uso:
  #   fecha = Date.new(2025, 6, 14)
  #   duracion = 30
  #   ocupados = Set.new([Time.utc(2025,6,14,11,30).to_i])
  #   turnos_para_dia(fecha, duracion, ocupados)
  #   # => [2025-06-14T11:00:00+00:00, 2025-06-14T12:00:00+00:00, ...]
  def turnos_para_dia(fecha, duracion, tiempos_ocupados)
    inicio_jornada, fin_jornada = jornada_laboral(fecha)
    hora_actual = hora_inicio(fecha, inicio_jornada, duracion)
    ultimo_turno = fin_jornada - duracion * 60

    turnos = []
    while hora_actual <= ultimo_turno
      turno_time = hora_actual # ya está en UTC
      turno_unix = turno_time.to_i

      turnos << turno_time.to_datetime unless tiempos_ocupados.include?(turno_unix)

      hora_actual += duracion * 60
    end

    turnos
  end

  def es_feriado?(fecha, feriados)
    feriados.any? { |feriado| feriado['dia'] == fecha.day && feriado['mes'] == fecha.month }
  end

  def dia_laboral?(fecha, feriados)
    (1..5).include?(fecha.wday) && !es_feriado?(fecha, feriados)
  end

  # Devuelve el rango de tiempo que representa la jornada laboral para una fecha determinada.
  # La jornada laboral se define localmente como de 08:00 a 18:00, y se convierte internamente a UTC.
  #
  # @param [Date] fecha - La fecha sobre la cual se desea obtener la jornada laboral (en UTC).
  #
  # @return [Array<Time>] Un arreglo con dos objetos `Time` en UTC:
  #   - El inicio de la jornada (08:00 hora local convertida a UTC)
  #   - El fin de la jornada (18:00 hora local convertida a UTC)
  #
  # Ejemplo (para huso horario -03:00):
  #   fecha = Date.new(2025, 6, 14)
  #   resultado = jornada_laboral(fecha)
  #   resultado[0] # => 2025-06-14 11:00:00 UTC (equivalente a 08:00 -03:00)
  #   resultado[1] # => 2025-06-14 21:00:00 UTC (equivalente a 18:00 -03:00)
  def jornada_laboral(fecha)
    [
      @proveedor_fecha.construir_hora_desde_local(fecha.year, fecha.month, fecha.day, 8, 0),  # 08:00 local → UTC
      @proveedor_fecha.construir_hora_desde_local(fecha.year, fecha.month, fecha.day, 18, 0)  # 18:00 local → UTC
    ]
  end

  # Calcula la hora desde la cual se deben comenzar a generar turnos para un día dado.
  #
  # @param [Date] fecha - Día en cuestión (en UTC)
  # @param [Time] inicio_jornada - Hora de inicio de la jornada laboral en UTC
  # @param [Integer] duracion - Duración de cada turno en minutos
  #
  # @return [Time] - Hora UTC desde la cual empezar a generar turnos para ese día
  #
  # Lógica:
  #   - Si la fecha es hoy, se calcula el próximo turno posible a partir del "ahora" UTC.
  #   - Si la fecha no es hoy, simplemente se empieza desde el inicio de jornada.
  #
  # Ejemplo:
  #   Si son las 15:43 UTC y `duracion = 20`, el próximo turno es a las 16:00 UTC
  #   y se devuelve ese valor si está dentro de la jornada.
  def hora_inicio(fecha, inicio_jornada, duracion)
    if fecha == @proveedor_dia.hoy
      proximo_turno = calcular_proximo_turno(fecha, duracion)
      [proximo_turno, inicio_jornada].max
    else
      inicio_jornada
    end
  end

  # Calcula el próximo turno alineado a múltiplos de duración, a partir del momento actual.
  #
  # @param [Date] fecha - Día actual en UTC
  # @param [Integer] duracion - Duración del turno en minutos
  #
  # @return [Time] - Hora UTC del próximo turno alineado
  #
  # Ejemplo:
  #   Si ahora es 2025-06-14 15:43:00 UTC y `duracion = 20`,
  #   el próximo turno es a las 16:00:00 UTC.
  def calcular_proximo_turno(fecha, duracion)
    ahora = @proveedor_fecha.ahora
    minutos = proximo_minuto_turno(ahora.min, duracion)
    hora = proxima_hora_turno(ahora.hour, ahora.min, duracion)

    @proveedor_fecha.construir_hora_utc(fecha.year, fecha.month, fecha.day, hora, minutos)
  end

  def proximo_minuto_turno(min_actual, duracion)
    ((min_actual / duracion.to_f).ceil * duracion) % 60
  end

  def proxima_hora_turno(hora_actual, min_actual, duracion)
    hora_actual + ((min_actual / duracion.to_f).ceil * duracion) / 60
  end
end
