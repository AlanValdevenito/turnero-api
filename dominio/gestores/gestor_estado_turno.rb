require_relative 'gestor_turnos'

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

  def self.modificar_estado_turno(turno, ahora, nuevo_estado)
    validar_estado_actual(turno)

    if nuevo_estado
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
    end
    turno
  end

  def self.cancelar_turno(turno, ahora, email, confirmacion)
    es_cercano = ocurre_proximas_24hs?(turno, ahora)
    verificar_duenio_turno(turno.usuario.email, email)
    raise ConfirmacionCancelarException if es_cercano && !confirmacion

    cambiar_estado_por_cancelacion(turno, es_cercano)
  end

  def self.verificar_duenio_turno(email_turno, email)
    raise TurnoNoPerteneceAUsuarioException if email_turno != email
  end

  def self.validar_estado_actual(turno)
    raise EstadoNoPermitidoException unless turno.estado == ESTADO_PENDIENTE
  end

  def self.cambiar_estado_por_cancelacion(turno, proximas_24hs)
    turno.estado = if proximas_24hs
                     ESTADO_AUSENTE
                   else
                     ESTADO_CANCELADO
                   end
    turno
  end

  def self.ocurre_proximas_24hs?(turno, ahora)
    turno.proximas_24hs?(ahora)
  end
end
