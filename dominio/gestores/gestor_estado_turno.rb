require_relative 'gestor_turnos'

MAXIMA_CANTIDAD_TURNOS_VISIBLES = 20
MAXIMA_CANTIDAD_TURNOS_HISTORIAL_VISIBLES = 15
DIAS_DE_DISPONIBILIDAD = 60
ESTADO_PENDIENTE = 'Pendiente'.freeze
ESTADO_AUSENTE = 'Ausente'.freeze
ESTADO_CANCELADO = 'Cancelado'.freeze
ESTADO_ASISTIDO = 'Asistido'.freeze

class GestorEstadoTurno
  def self.validar_turno_pasado(turno, ahora)
    raise TurnoYaPasadoException if turno.fecha_hora.to_time < ahora.to_time
  end

  def self.validar_turno_futuro(turno, ahora)
    raise TurnoFuturoException if turno.fecha_hora.to_time > ahora.to_time
  end

  def self.modificar_estado_turno(turno, nuevo_estado, ahora)
    case nuevo_estado
    when ESTADO_CANCELADO
      validar_turno_pasado(turno, ahora)
      turno.estado = ESTADO_CANCELADO
    when ESTADO_ASISTIDO
      validar_turno_futuro(turno, ahora)
      turno.estado = ESTADO_ASISTIDO
    when ESTADO_AUSENTE
      validar_turno_futuro(turno, ahora)
      turno.estado = ESTADO_AUSENTE
    else
      raise EstadoInvalidoException
    end
    turno
  end

  def self.cancelar_turno(turno, proximas_24hs)
    turno.estado = if proximas_24hs
                     ESTADO_AUSENTE
                   else
                     ESTADO_CANCELADO
                   end
    turno
  end
end
