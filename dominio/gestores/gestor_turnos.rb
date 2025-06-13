require_relative '../excepciones/turno_pasado_exception'
require_relative '../excepciones/turno_futuro_exception'
require_relative '../excepciones/estado_no_permitido_exception'

MAXIMA_CANTIDAD_TURNOS_VISIBLES = 20
MAXIMA_CANTIDAD_TURNOS_HISTORIAL_VISIBLES = 15
ESTADO_PENDIENTE = 'Pendiente'.freeze
ESTADO_AUSENTE = 'Ausente'.freeze
ESTADO_CANCELADO = 'Cancelado'.freeze
ESTADO_ASISTIDO = 'Asistido'.freeze

class GestorTurnos
  def initialize(repositorio_turnos, proveedor_dia, proveedor_feriados, proveedor_hora)
    @repositorio_turnos = repositorio_turnos
    @proveedor_dia = proveedor_dia
    @proveedor_hora = proveedor_hora
    @proveedor_feriados = proveedor_feriados
    @calculador_disponibilidad = CalculadorDeDisponibilidad.new(@proveedor_dia, @proveedor_hora, proveedor_feriados)
  end

  def turnos_paciente(usuario) = turnos_recientes(@repositorio_turnos.buscar_por_usuario(usuario))

  def turnos_medico(medico) = turnos_recientes(@repositorio_turnos.buscar_por_medico(medico))

  def crear_turno(medico, usuario, fecha, hora)
    raise FechaNoValidaException unless es_fecha_valida?(fecha)

    turnos_existentes = @repositorio_turnos.buscar_por_medico(medico)
    turnos_existentes.each do |turno|
      raise TurnoYaExisteException if turno.fecha == fecha && turno.hora == hora
    end

    @repositorio_turnos.save(Turno.crear(medico, usuario, fecha, hora))
  end

  def disponibilidad_de_medico(medico)
    duracion_turno = medico.especialidad.duracion_de_turnos
    fecha_inicio = @proveedor_dia.hoy
    fecha_fin = fecha_inicio + 60

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
    raise FechaNoValidaException if @calculador_disponibilidad.dia_laboral?(fecha, feriados) == false

    true
  end

  def proximos_turnos_paciente(usuario)
    turnos = @repositorio_turnos.buscar_por_usuario(usuario).select { |turno| turno.fecha_hora >= @proveedor_hora.ahora && turno.estado == ESTADO_PENDIENTE }
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

    validar_estado_actual(turno)

    ahora = fecha_y_hora_actual

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
    @repositorio_turnos.save(turno)
    turno
  end

  def ocurre_proximas_24hs?(turno)
    turno.proximas_24hs?(@proveedor_hora.ahora)
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

  def validar_estado_actual(turno)
    raise EstadoNoPermitidoException unless turno.estado == ESTADO_PENDIENTE
  end

  def fecha_y_hora_actual
    hoy = @proveedor_dia.hoy
    ahora = @proveedor_hora.ahora
    DateTime.parse("#{hoy} #{ahora}")
  end

  def validar_turno_pasado(turno, ahora)
    raise TurnoYaPasadoException if turno.fecha_hora.to_time < ahora.to_time
  end

  def validar_turno_futuro(turno, ahora)
    raise TurnoFuturoException if turno.fecha_hora.to_time > ahora.to_time
  end
end
