DURACION_PENALIDAD = 3

class Penalizador
  def initialize(proveedor_hora)
    @proveedor_hora = proveedor_hora
  end

  def chequeo_penalizacion_vigente(usuario)
    # si intenta sacar turno y tiene una penalización vigente, lanzo excepción
    if usuario.ultima_penalizacion &&
       (@proveedor_hora.ahora - usuario.ultima_penalizacion.to_time < DURACION_PENALIDAD * 60)
      raise PenalizacionPorReputacionException
    end
  end
end
