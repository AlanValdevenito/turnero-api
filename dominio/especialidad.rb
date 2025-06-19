class Especialidad
  attr_reader :created_on, :updated_on
  attr_accessor :id, :nombre, :duracion_de_turnos, :limite_turnos_por_usuario

  ESTADO_PENDIENTE = 'Pendiente'.freeze

  def initialize(nombre, duracion_de_turnos, limite_turnos_por_usuario, id = nil)
    @id = id
    @nombre = nombre
    @duracion_de_turnos = duracion_de_turnos
    @limite_turnos_por_usuario = limite_turnos_por_usuario
  end

  def tiene_limite_disponible?(turnos_usuario)
    return true if @limite_turnos_por_usuario.nil?

    turnos_especialidad_pendientes = turnos_usuario.select do |turno|
      turno.medico.especialidad.nombre == @nombre &&
        turno.estado == ESTADO_PENDIENTE
    end

    turnos_especialidad_pendientes.count < @limite_turnos_por_usuario
  end
end
