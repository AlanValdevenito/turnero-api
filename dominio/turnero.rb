require_relative '../dominio/excepciones/excepciones_registracion'
require_relative '../dominio/excepciones/medico_no_encontrado_exception'
require_relative '../dominio/excepciones/usuario_no_encontrado_exception'
require_relative '../dominio/excepciones/turno_ya_existe_exception'
require_relative '../dominio/excepciones/no_hay_proximos_turnos_exception'
require_relative '../dominio/excepciones/fecha_no_valida_exception'
require_relative '../dominio/gestores/gestor_usuarios'
require_relative '../dominio/gestores/gestor_turnos'

MEDICOS_DISPONIBLES = 7
TURNOS_DISPONIBLES = 3
MAXIMA_CANTIDAD_TURNOS_VISIBLES = 20
ESTADO_PENDIENTE = 'Pendiente'.freeze
ESTADO_AUSENTE = 'Ausente'.freeze
ESTADO_CANCELADO = 'Cancelado'.freeze
ESTADO_ASISTIDO = 'Asistido'.freeze

class Turnero # rubocop:disable Metrics/ClassLength
  # rubocop:disable Metrics/ParameterLists
  def initialize(repositorio_usuarios, repositorio_medicos, repositorio_especialidades, repositorio_turnos, proveedor_dia, proveedor_feriados, proveedor_hora)
    @repositorio_medicos = repositorio_medicos
    @repositorio_especialidades = repositorio_especialidades
    @gestor_usuarios = GestorUsuarios.new(repositorio_usuarios)
    @gestor_turnos = GestorTurnos.new(
      repositorio_turnos,
      proveedor_dia,
      proveedor_feriados,
      proveedor_hora
    )
  end
  # rubocop:enable Metrics/ParameterLists

  def crear_usuario(email, telegram_id = nil)
    @gestor_usuarios.crear_usuario(email, telegram_id)
  end

  def usuarios
    @gestor_usuarios.usuarios
  end

  def buscar_usuario_por_email(email)
    @gestor_usuarios.buscar_usuario_por_email(email)
  end

  def buscar_usuario_por_telegram_id(telegram_id)
    @gestor_usuarios.buscar_usuario_por_telegram_id(telegram_id)
  end

  def medicos
    @repositorio_medicos.all
  end

  def especialidades
    @repositorio_especialidades.all
  end

  def turnos_paciente(email)
    usuario = buscar_usuario_por_email(email)
    @gestor_turnos.turnos_paciente(usuario)
  end

  def turnos_medico(matricula)
    medico = buscar_medico_por_matricula(matricula)
    @gestor_turnos.turnos_medico(medico)
  end

  def crear_turno(matricula, fecha, hora, telegram_id)
    medico = buscar_medico_por_matricula(matricula)
    usuario = buscar_usuario_por_telegram_id(telegram_id)
    @gestor_turnos.crear_turno(medico, usuario, fecha, hora)
  end

  def crear_medico(nombre, apellido, matricula, especialidad_nombre)
    especialidad = @repositorio_especialidades.buscar_por_nombre(especialidad_nombre)
    medico = Medico.new(nombre, apellido, matricula, especialidad)
    @repositorio_medicos.save(medico)
  end

  def crear_especialidad(nombre, duracion_de_turnos)
    especialidad = Especialidad.new(nombre, duracion_de_turnos)
    @repositorio_especialidades.save(especialidad)
  end

  def medicos_disponibles
    @repositorio_medicos.all.first(MEDICOS_DISPONIBLES)
  end

  def buscar_medico_por_matricula(matricula)
    medico = @repositorio_medicos.buscar_por_matricula(matricula)
    raise MedicoNoEncontradoException unless medico

    medico
  end

  def disponibilidad_de_medico(matricula)
    medico = buscar_medico_por_matricula(matricula)
    @gestor_turnos.disponibilidad_de_medico(medico)
  end

  def proximos_turnos_paciente(telegram_id)
    usuario = buscar_usuario_por_telegram_id(telegram_id)
    @gestor_turnos.proximos_turnos_paciente(usuario)
  end

  def modificar_estado_turno(id, nuevo_estado)
    turno = @repositorio_turnos.buscar_por_id(id)
    raise TurnoNoEncontradoException unless turno

    validar_estado_actual(turno)

    ahora = fecha_y_hora_actual

    case nuevo_estado
    when ESTADO_CANCELADO
      validar_turno_pasado(turno, ahora)

      turno.estado = ESTADO_CANCELADO
    when ESTADO_ASISTIDO
      validar_turno_futuro(turno, ahora)
      turno.estado = ESTADO_ASISTIDO
    when ESTADO_AUSENT
      validar_turno_futuro(turno, ahora)

      turno.estado = ESTADO_AUSENTE
    else
      raise EstadoInvalidoException
    end

    @repositorio_turnos.save(turno)
    turno
  end

  def validar_estado_actual(turno)
    raise EstadoInvalidoException unless turno.estado == ESTADO_PENDIENTE
  end

  def fecha_y_hora_actual
    hoy = @proveedor_dia.hoy
    ahora = @proveedor_hora.ahora
    DateTime.parse("#{hoy} #{ahora.strftime('%H:%M:%S')}")
  end

  def validar_turno_futuro(turno, ahora)
    raise EstadoInvalidoException if turno.fecha_hora > ahora
  end

  def validar_turno_pasado(turno, ahora)
    raise EstadoInvalidoException if turno.fecha_hora < ahora
  end
end
