require_relative '../proveedor_dia_interfaz'

class ProveedorDia < ProveedorDiaInterfaz
  def hoy
    Date.today
  end
end
