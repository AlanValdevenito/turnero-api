Dir[File.join(__dir__, '../dominio/excepciones', '*.rb')].each { |file| require file }
require_relative 'gestor_estado_turno'

MAXIMA_CANTIDAD_TURNOS_VISIBLES = 20
MAXIMA_CANTIDAD_TURNOS_HISTORIAL_VISIBLES = 15
DIAS_DE_DISPONIBILIDAD = 60

class GestorTurnos
  def initialize(repositorio_turnos, proveedor_fecha, proveedor_feriados, penalizador)
    @repositorio_turnos = repositorio_turnos
    @proveedor_fecha = proveedor_fecha
    @proveedor_feriados = proveedor_feriados
    @calculador_disponibilidad = CalculadorDeDisponibilidad.new(@proveedor_fecha, proveedor_feriados)
    @calculador_reputacion = CalculadorReputacion.new(@repositorio_turnos)
    @penalizador = penalizador
  end

  def turnos_paciente(usuario) = turnos_recientes(@repositorio_turnos.buscar_por_usuario(usuario))

  def turnos_medico(medico) = turnos_recientes(@repositorio_turnos.buscar_por_medico(medico))

  def penalizar_si_corresponde(usuario)
    @penalizador.penalizar_si_corresponde(usuario, @calculador_reputacion.calcular_reputacion(usuario))
  end

  def crear_turno(medico, usuario, fecha, hora)
    raise FechaNoValidaException unless es_fecha_valida?(fecha)

    turno = Turno.crear(medico, usuario, fecha, hora)

    validar_turnos_del_medico(turno)
    validar_turnos_del_usuario(turno)

    raise LimiteTurnosExcedidoException unless cumple_limite_turnos?(usuario, medico.especialidad)

    @repositorio_turnos.save(turno)
  end

  def validar_turnos_del_medico(otro_turno)
    turnos_existentes = @repositorio_turnos.buscar_por_medico(otro_turno.medico)
    turnos_existentes.each do |turno|
      next unless turno.estado == 'Pendiente'
      raise TurnoYaExisteException if turno.fecha == otro_turno.fecha && turno.hora == otro_turno.hora
    end
  end

  def validar_turnos_del_usuario(otro_turno)
    turnos_existentes = @repositorio_turnos.buscar_por_usuario(otro_turno.usuario)
    turnos_existentes.each do |turno|
      next unless turno.estado == 'Pendiente' && turno.fecha == otro_turno.fecha
      raise SuperposicionDeTurnosException if turno.se_superpone_con?(otro_turno)
    end
  end

  def cumple_limite_turnos?(usuario, especialidad)
    turnos_usuario = @repositorio_turnos.buscar_por_usuario(usuario)
    return true if turnos_usuario.nil? || turnos_usuario.empty?

    especialidad.tiene_limite_disponible?(turnos_usuario)
  end

  def disponibilidad_de_medico(medico)
    duracion_turno = medico.especialidad.duracion_de_turnos
    fecha_inicio = @proveedor_fecha.hoy
    fecha_fin = fecha_inicio + DIAS_DE_DISPONIBILIDAD

    turnos_existentes = @repositorio_turnos.obtener_turnos_existentes(medico.id, fecha_inicio, fecha_fin)

    @calculador_disponibilidad.turnos_disponibles(
      duracion_turno,
      turnos_existentes,
      TURNOS_DISPONIBLES,
      fecha_inicio,
      fecha_fin
    )
  end

  def es_fecha_valida?(fecha)
    fecha = DateTime.parse(fecha)
    feriados = @proveedor_feriados.feriados(fecha.year)
    @calculador_disponibilidad.dia_laboral?(fecha, feriados) || raise(FechaNoValidaException)
  end

  def proximos_turnos_paciente(usuario)
    turnos = @repositorio_turnos.buscar_por_usuario(usuario).select { |turno| turno.fecha_hora >= @proveedor_fecha.ahora && turno.estado == ESTADO_PENDIENTE }
                                .sort_by(&:fecha_hora).first(MAXIMA_CANTIDAD_TURNOS_VISIBLES)
    raise NoHayProximosTurnosException if turnos.nil? || (turnos.respond_to?(:empty?) && turnos.empty?)

    turnos
  end

  def historial_turnos_paciente(usuario)
    turnos = @repositorio_turnos.buscar_por_usuario(usuario).reject { |turno| turno.estado == ESTADO_PENDIENTE }
                                .sort_by(&:fecha_hora).reverse.first(MAXIMA_CANTIDAD_TURNOS_HISTORIAL_VISIBLES)

    raise NoHayHistorialTurnosException if turnos.empty?

    turnos
  end

  def buscar_turno_por_id(turno_id)
    turno = @repositorio_turnos.buscar_por_id(turno_id)
    raise TurnoNoEncontradoException unless turno

    turno
  end

  def modificar_estado_turno(turno_id, nuevo_estado)
    validar_turno_id(turno_id)
    turno = buscar_turno_por_id(turno_id)
    turno = GestorEstadoTurno.modificar_estado_turno(turno, @proveedor_fecha.ahora, nuevo_estado)
    @repositorio_turnos.save(turno)
    @penalizador.actualizar_flag_penalizable(turno.usuario, turno.estado)
    turno
  end

  def cancelar_turno(turno_id, email, confirmacion)
    validar_turno_id(turno_id)
    turno = buscar_turno_por_id(turno_id)
    turno = GestorEstadoTurno.cancelar_turno(turno, @proveedor_fecha.ahora, email, confirmacion)
    @repositorio_turnos.save(turno)
    @penalizador.actualizar_flag_penalizable(turno.usuario, turno.estado)
    turno
  end

  private

  def validar_turno_id(turno_id)
    id = Integer(turno_id)
    raise ArgumentError if id <= 0 || id > 2**31 - 1

    id
  end

  def turnos_recientes(turnos)
    turnos.sort_by(&:fecha_hora).reverse.first(MAXIMA_CANTIDAD_TURNOS_VISIBLES)
  end
end
