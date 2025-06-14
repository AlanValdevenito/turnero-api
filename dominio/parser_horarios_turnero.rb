class ParserHorariosTurnero
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

  def parsear_turno(turno)
    TurnoParseado.new(
      id: turno.id,
      medico: turno.medico,
      usuario: turno.usuario,
      estado: turno.estado,
      fecha_hora: @proveedor_hora.cambiar_a_huso_horario_local(turno.fecha_hora)
    )
  end

  def parsear_turnos(turnos)
    Array(turnos).map { |turno| parsear_turno(turno) }
  end

  def parsear_horarios(horarios_utc)
    Array(horarios_utc).map { |dt| @proveedor_hora.cambiar_a_huso_horario_local(dt) }
  end
end

class TurnoParseado
  attr_reader :id, :medico, :usuario, :estado, :fecha_hora

  def initialize(id:, medico:, usuario:, estado:, fecha_hora:)
    @id = id
    @medico = medico
    @usuario = usuario
    @estado = estado
    @fecha_hora = fecha_hora
  end
end
