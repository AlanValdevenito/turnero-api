class CalculadorDeDisponibilidad
  attr_reader :proveedor_dia, :proveedor_hora, :proveedor_feriados

  def initialize(proveedor_dia, proveedor_hora, proveedor_feriados)
    @proveedor_dia = proveedor_dia
    @proveedor_hora = proveedor_hora
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

  def turnos_para_dia(fecha, duracion, tiempos_ocupados)
    inicio_jornada, fin_jornada = jornada_laboral(fecha)
    hora_actual = hora_inicio(fecha, inicio_jornada, duracion)
    ultimo_turno = fin_jornada - duracion * 60

    turnos = []
    while hora_actual <= ultimo_turno
      hora = @proveedor_hora.formatear(hora_actual)
      turnos << @proveedor_hora.time_to_date_time(hora) unless tiempos_ocupados.include?(hora_actual.to_i)
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

  def jornada_laboral(fecha)
    [
      @proveedor_hora.construir_hora(fecha.year, fecha.month, fecha.day, 8, 0),
      @proveedor_hora.construir_hora(fecha.year, fecha.month, fecha.day, 18, 0)
    ]
  end

  def hora_inicio(fecha, inicio_jornada, duracion)
    if fecha == @proveedor_dia.hoy
      proximo_turno = calcular_proximo_turno(fecha, duracion)
      [proximo_turno, inicio_jornada].max
    else
      inicio_jornada
    end
  end

  def calcular_proximo_turno(fecha, duracion)
    ahora = @proveedor_hora.ahora
    minutos = proximo_minuto_turno(ahora.min, duracion)
    hora = proxima_hora_turno(ahora.hour, ahora.min, duracion)

    @proveedor_hora.construir_hora(fecha.year, fecha.month, fecha.day, hora, minutos)
  end

  def proximo_minuto_turno(min_actual, duracion)
    ((min_actual / duracion.to_f).ceil * duracion) % 60
  end

  def proxima_hora_turno(hora_actual, min_actual, duracion)
    hora_actual + ((min_actual / duracion.to_f).ceil * duracion) / 60
  end
end
