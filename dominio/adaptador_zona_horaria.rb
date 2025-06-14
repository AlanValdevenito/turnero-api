class AdaptadorZonaHoraria
  def initialize(proveedor_hora)
    @proveedor_hora = proveedor_hora
  end

  def parsear_a_utc(fecha, hora)
    anio, mes, dia = fecha.split('-').map(&:to_i)
    hora_num, minuto = hora.split(':').map(&:to_i)
    utc_time = @proveedor_hora.construir_hora_desde_local(anio, mes, dia, hora_num, minuto)
    fecha_utc_str = utc_time.strftime('%Y-%m-%d')
    hora_utc_str = utc_time.strftime('%H:%M')
    [fecha_utc_str, hora_utc_str]
  end

  def adaptar_zona_horaria(turno)
    fecha_hora_local = @proveedor_hora.cambiar_a_huso_horario_local(turno.fecha_hora)
    fecha_hora_local = fecha_hora_local.to_datetime unless fecha_hora_local.is_a?(DateTime)
    turno.cambiar_fecha_hora(fecha_hora_local)
    turno
  end

  def adaptar_zona_horaria_turnos(turnos)
    Array(turnos).map { |turno| adaptar_zona_horaria(turno) }
  end

  def adaptar_zona_horarios(horarios_utc)
    Array(horarios_utc).map { |dt| @proveedor_hora.cambiar_a_huso_horario_local(dt) }
  end
end
