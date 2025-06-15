Dir[File.join(__dir__, '../dominio/excepciones', '*.rb')].each { |file| require file }
require_relative '../dominio/gestores/gestor_usuarios'
require_relative '../dominio/gestores/gestor_turnos'
require_relative 'adaptador_zona_horaria'

MEDICOS_DISPONIBLES = 7
TURNOS_DISPONIBLES = 3

class Turnero
  # rubocop:disable Metrics/ParameterLists
  def initialize(repositorio_usuarios, repositorio_medicos, repositorio_especialidades, repositorio_turnos, proveedor_dia, proveedor_feriados, proveedor_hora)
    @repositorio_medicos = repositorio_medicos
    @repositorio_especialidades = repositorio_especialidades
    @gestor_usuarios = GestorUsuarios.new(repositorio_usuarios)
    @gestor_turnos = GestorTurnos.new(
      repositorio_turnos,
      proveedor_dia,
      proveedor_feriados,
      proveedor_hora,
      Penalizador.new(proveedor_hora, @gestor_usuarios)
    )
    @adaptador_zona_horaria = AdaptadorZonaHoraria.new(proveedor_hora)
  end
  # rubocop:enable Metrics/ParameterLists

  def crear_usuario(email, telegram_id = nil)
    @gestor_usuarios.crear_usuario(email, telegram_id)
  end

  def usuario_registrado?(telegram_id)
    @gestor_usuarios.buscar_usuario_por_telegram_id(telegram_id)
  end

  def usuarios
    @gestor_usuarios.usuarios
  end

  def buscar_usuario_por_email(email)
    @gestor_usuarios.buscar_usuario_por_email(email)
  end

  def medicos
    @repositorio_medicos.all
  end

  def especialidades
    @repositorio_especialidades.all
  end

  def turnos_paciente(email)
    usuario = buscar_usuario_por_email(email)
    turnos = @gestor_turnos.turnos_paciente(usuario)
    @adaptador_zona_horaria.adaptar_zona_horaria_turnos(turnos)
  end

  def turnos_medico(matricula)
    medico = buscar_medico_por_matricula(matricula)
    turnos = @gestor_turnos.turnos_medico(medico)
    @adaptador_zona_horaria.adaptar_zona_horaria_turnos(turnos)
  end

  def crear_turno(matricula, fecha, hora, email)
    medico = buscar_medico_por_matricula(matricula)
    usuario = buscar_usuario_por_email(email)
    fecha_utc, hora_utc = @adaptador_zona_horaria.parsear_a_utc(fecha, hora)
    turno = @gestor_turnos.crear_turno(medico, usuario, fecha_utc, hora_utc)
    @adaptador_zona_horaria.adaptar_zona_horaria(turno)
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
    @repositorio_medicos.all.sample(MEDICOS_DISPONIBLES)
  end

  def medicos_disponibles_especialidad(especialidad_nombre)
    especialidad = @repositorio_especialidades.buscar_por_nombre(especialidad_nombre)
    medicos = @repositorio_medicos.buscar_por_especialidad(especialidad).sample(MEDICOS_DISPONIBLES)
    raise EspecialidadSinMedicosException if medicos.empty?

    medicos
  end

  def buscar_medico_por_matricula(matricula)
    medico = @repositorio_medicos.buscar_por_matricula(matricula)
    raise MedicoNoEncontradoException unless medico

    medico
  end

  def disponibilidad_de_medico(matricula)
    medico = buscar_medico_por_matricula(matricula)
    horarios = @gestor_turnos.disponibilidad_de_medico(medico)
    @adaptador_zona_horaria.adaptar_zona_horarios(horarios)
  end

  def proximos_turnos_paciente(email)
    usuario = buscar_usuario_por_email(email)
    turnos = @gestor_turnos.proximos_turnos_paciente(usuario)
    @adaptador_zona_horaria.adaptar_zona_horaria_turnos(turnos)
  end

  def historial_turnos_paciente(email)
    usuario = buscar_usuario_por_email(email)
    turnos = @gestor_turnos.historial_turnos_paciente(usuario)
    @adaptador_zona_horaria.adaptar_zona_horaria_turnos(turnos)
  end

  def modificar_estado_turno(turno_id, nuevo_estado)
    @gestor_turnos.modificar_estado_turno(turno_id, nuevo_estado)
  end

  def cancelar_turno(id, proximas_24hs, email)
    @gestor_turnos.cancelar_turno(id, proximas_24hs, email)
  end

  def ocurre_proximas_24hs?(turno)
    @gestor_turnos.ocurre_proximas_24hs?(turno)
  end
end
