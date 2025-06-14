require_relative '../proveedor_dia_interfaz'

class ProveedorDia < ProveedorDiaInterfaz
  def initialize(huso_horario = '-03:00')
    super()
    @huso_horario = huso_horario
  end

  # @return [Date] Fecha de "hoy" en UTC — usada para lógica del sistema
  #
  # Ejemplo:
  #   Si ahora en UTC es 2025-06-13 03:30:00, devuelve Date.new(2025, 6, 13)
  def hoy
    Time.now.utc.to_date
  end

  # @param [Date, Time, DateTime] fecha_utc - valor en UTC
  # @return [Time] El mismo momento en horario local (por ejemplo, UTC-3)
  def cambiar_a_huso_horario_local(fecha_utc)
    fecha_utc.to_time.getlocal(@huso_horario)
  end

  attr_reader :huso_horario
end
