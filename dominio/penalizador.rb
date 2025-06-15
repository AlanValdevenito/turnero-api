DURACION_PENALIDAD = 3
REPUTACION_MINIMA = 80

class Penalizador
  def initialize(proveedor_hora, gestor_usuarios)
    @proveedor_hora = proveedor_hora
    @gestor_usuarios = gestor_usuarios
  end

  def penalizar_si_corresponde(usuario, reputacion)
    # Chequeo de penalización vigente
    chequeo_penalizacion_vigente(usuario)

    # si no es penalizable, no se hace nada
    return unless usuario.penalizable

    # penalizo si tiene baja reputacion
    if reputacion < REPUTACION_MINIMA
      # actualizo la ultima penalizacion del usuario a ahora
      # y lo marco como no penalizable
      usuario.ultima_penalizacion = @proveedor_hora.ahora.to_datetime
      usuario.penalizable = false
      @gestor_usuarios.actualizar(usuario)
      raise PenalizacionPorReputacionException
    end
  end

  def chequeo_penalizacion_vigente(usuario)
    # si intenta sacar turno y tiene una penalización vigente, lanzo excepción
    if usuario.ultima_penalizacion &&
       (@proveedor_hora.ahora - usuario.ultima_penalizacion.to_time < DURACION_PENALIDAD * 60)
      raise PenalizacionPorReputacionException
    end
  end

  def actualizar_flag_penalizable(usuario, estado)
    if estado == ESTADO_AUSENTE
      usuario.penalizable = true
      @gestor_usuarios.actualizar(usuario)
    end
  end
end
