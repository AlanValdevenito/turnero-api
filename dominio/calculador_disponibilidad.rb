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
    hora_actual = hora_inicio(fecha, inicio_jornada)
    ultimo_turno = fin_jornada - duracion * 60

    turnos = []
    while hora_actual <= ultimo_turno
      turnos << hora_actual unless tiempos_ocupados.include?(hora_actual.to_i)
      hora_actual += duracion * 60
    end

    turnos
  end

  def self.dia_laboral?(fecha)
    (1..5).include?(fecha.wday)
  end

  def self.jornada_laboral(fecha)
    [
      Time.local(fecha.year, fecha.month, fecha.day, 8, 0, 0),
      Time.local(fecha.year, fecha.month, fecha.day, 18, 0, 0)
    ]
  end

  def self.hora_inicio(fecha, inicio_jornada)
    fecha == Date.today ? [Time.now, inicio_jornada].max : inicio_jornada
  end
end
