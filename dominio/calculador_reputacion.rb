class CalculadorReputacion
  def initialize(repositorio_turnos)
    @repositorio_turnos = repositorio_turnos
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
end
