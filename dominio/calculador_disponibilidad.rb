class CalculadorDeDisponibilidad
  def self.turnos_disponibles(duracion_turno, turnos_existentes, cantidad, fecha_inicio, fecha_fin)
    tiempos_ocupados = Set.new(turnos_existentes.map { |t| t[:fecha_hora].to_i })

    turnos_disponibles = []

    (fecha_inicio...fecha_fin).each do |fecha|
      next unless dia_laboral?(fecha)

      turnos_disponibles.concat(turnos_para_dia(fecha, duracion_turno, tiempos_ocupados))
    end

    turnos_disponibles.first(cantidad)
  end

  def self.turnos_para_dia(fecha, duracion, tiempos_ocupados)
    inicio_jornada, fin_jornada = jornada_laboral(fecha)
    hora_actual = hora_inicio(fecha, inicio_jornada, duracion)
    ultimo_turno = fin_jornada - duracion * 60

    turnos = []
    while hora_actual <= ultimo_turno
      turnos << DateTime.parse(hora_actual.strftime('%Y-%m-%d %H:%M:%S')) unless tiempos_ocupados.include?(hora_actual.to_i)
      hora_actual += duracion * 60
    end

    turnos
  end

  def self.es_feriado?(fecha)
    feriados = ProveedorFeriados.new.feriados(fecha.year)
    feriados.any? do |feriado|
      feriado['dia'] == fecha.day && feriado['mes'] == fecha.month
    end
  end

  def self.dia_laboral?(fecha)
    (1..5).include?(fecha.wday) && !es_feriado?(fecha)
  end

  def self.jornada_laboral(fecha)
    [
      Time.local(fecha.year, fecha.month, fecha.day, 8, 0, 0),
      Time.local(fecha.year, fecha.month, fecha.day, 18, 0, 0)
    ]
  end

  def self.hora_inicio(fecha, inicio_jornada, duracion)
    if fecha == Date.today
      proximo_turno = calcular_proximo_turno(fecha, duracion)
      [proximo_turno, inicio_jornada].max
    else
      inicio_jornada
    end
  end

  def self.calcular_proximo_turno(fecha, duracion)
    ahora = Time.now
    minutos = proximo_minuto_turno(ahora.min, duracion)
    hora = proxima_hora_turno(ahora.hour, ahora.min, duracion)
    Time.local(fecha.year, fecha.month, fecha.day, hora, minutos, 0)
  end

  def self.proximo_minuto_turno(min_actual, duracion)
    ((min_actual / duracion.to_f).ceil * duracion) % 60
  end

  def self.proxima_hora_turno(hora_actual, min_actual, duracion)
    hora_actual + ((min_actual / duracion.to_f).ceil * duracion) / 60
  end
end
