DURACION_PENALIDAD = 3

class Penalizador
  def initialize(repositorio_turnos, proveedor_hora)
    @repositorio_turnos = repositorio_turnos
    @proveedor_hora = proveedor_hora
  end

  def calcular_reputacion(usuario)
    asistidos, cancelados, pendientes, total = contar_turnos(usuario).values

    divisor = total - pendientes

    return 100 if divisor.zero?

    ((asistidos + cancelados).to_f / divisor * 100).round
  end

  def contar_turnos(usuario)
    turnos = @repositorio_turnos.buscar_por_usuario(usuario)
    asistidos = turnos.count { |t| t.estado == ESTADO_ASISTIDO }
    cancelados = turnos.count { |t| t.estado == ESTADO_CANCELADO }
    pendientes = turnos.count { |t| t.estado == ESTADO_PENDIENTE }
    total = turnos.count
    { asistidos:, cancelados:, pendientes:, total: }
  end

  def chequeo_penalizacion_vigente(usuario)
    # si intenta sacar turno y tiene una penalización vigente, lanzo excepción
    if usuario.ultima_penalizacion &&
       (@proveedor_hora.ahora - usuario.ultima_penalizacion.to_time < DURACION_PENALIDAD * 60)
      raise PenalizacionPorReputacionException
    end
  end
end
