require_relative '../dominio/excepciones/excepciones_registracion'
require_relative '../dominio/excepciones/medico_no_encontrado_exception'
require_relative '../dominio/excepciones/usuario_no_encontrado_exception'
require_relative '../dominio/excepciones/turno_ya_existe_exception'
require_relative '../dominio/calculador_disponibilidad'

MEDICOS_DISPONIBLES = 7
TURNOS_DISPONIBLES = 3
MAXIMA_CANTIDAD_TURNOS_VISIBLES = 20

class Turnero
  # rubocop:disable Metrics/ParameterLists
  def initialize(repositorio_usuarios, repositorio_medicos, repositorio_especialidades, repositorio_turnos, proveedor_dia, proveedor_feriados)
    @repositorio_usuarios = repositorio_usuarios
    @repositorio_medicos = repositorio_medicos
    @repositorio_especialidades = repositorio_especialidades
    @repositorio_turnos = repositorio_turnos
    @proveedor_dia = proveedor_dia
    @proveedor_feriados = proveedor_feriados
  end
  # rubocop:enable Metrics/ParameterLists

  def crear_usuario(email, telegram_id = nil)
    raise TelegramIdEnUsoException if telegram_id && @repositorio_usuarios.buscar_por_telegram_id(telegram_id)
    raise EmailEnUsoException if buscar_usuario_por_email(email)

    begin
      usuario = Usuario.new(email, nil, telegram_id)
    rescue ArgumentError
      raise EmailObligatorioException
    end

    @repositorio_usuarios.save(usuario)
    usuario
  end

  def usuarios
    @repositorio_usuarios.all
  end

  def medicos
    @repositorio_medicos.all
  end

  def especialidades
    @repositorio_especialidades.all
  end

  def turnos_paciente(email)
    usuario = @repositorio_usuarios.buscar_por_email(email)
    raise UsuarioNoEncontradoException unless usuario

    @repositorio_turnos
      .buscar_por_usuario(usuario)
      .sort_by(&:fecha_hora)
      .first(MAXIMA_CANTIDAD_TURNOS_VISIBLES)
  end

  def turnos_medico(matricula)
    medico = @repositorio_medicos.buscar_por_matricula(matricula)
    raise MedicoNoEncontradoException unless medico

    @repositorio_turnos.buscar_por_medico(medico).sort_by(&:fecha_hora).first(MAXIMA_CANTIDAD_TURNOS_VISIBLES)
  end

  def crear_turno(matricula, fecha, hora, telegram_id)
    medico = buscar_medico_por_matricula(matricula)
    raise MedicoNoEncontradoException unless medico

    usuario = @repositorio_usuarios.buscar_por_telegram_id(telegram_id)
    raise UsuarioNoEncontradoException unless usuario

    turnos_existentes = @repositorio_turnos.buscar_por_medico(medico)

    turnos_existentes.each do |turno|
      raise TurnoYaExisteException if turno.fecha == fecha && turno.hora == hora
    end

    turno = Turno.crear(medico, usuario, fecha, hora)
    @repositorio_turnos.save(turno)
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

  def buscar_usuario_por_email(email)
    @repositorio_usuarios.buscar_por_email(email)
  end

  def buscar_usuario_por_telegram_id(telegram_id)
    @repositorio_usuarios.buscar_por_telegram_id(telegram_id)
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
    duracion_turno = medico.especialidad.duracion_de_turnos

    fecha_inicio = @proveedor_dia.hoy
    fecha_fin = fecha_inicio + 60

    turnos_existentes = @repositorio_turnos.obtener_turnos_existentes(medico.id, fecha_inicio, fecha_fin)

    calculador_disponibilidad = CalculadorDeDisponibilidad.new(@proveedor_dia, ProveedorHora.new)

    calculador_disponibilidad.turnos_disponibles(
      duracion_turno,
      turnos_existentes,
      TURNOS_DISPONIBLES,
      fecha_inicio,
      fecha_fin
    )
  end
end
