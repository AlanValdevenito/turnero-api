require_relative '../dominio/excepciones/excepciones_registracion'
require_relative '../dominio/excepciones/medico_no_encontrado_exception'

MEDICOS_DISPONIBLES = 7
TURNOS_DISPONIBLES = 3

class Turnero
  def initialize(repositorio_usuarios, repositorio_medicos, repositorio_especialidades, repositorio_turnos)
    @repositorio_usuarios = repositorio_usuarios
    @repositorio_medicos = repositorio_medicos
    @repositorio_especialidades = repositorio_especialidades
    @repositorio_turnos = repositorio_turnos
  end

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

  def medicos_disponibles
    @repositorio_medicos.all.first(MEDICOS_DISPONIBLES)
  end

  def disponibilidad_de_medico(matricula)
    medico = @repositorio_medicos.buscar_por_matricula(matricula)
    raise MedicoNoEncontradoException unless medico

    duracion_turno = medico.especialidad.duracion_de_turnos
    fecha_inicio = Date.today
    fecha_fin = fecha_inicio + 60

    turnos_existentes = @repositorio_turnos.obtener_turnos_existentes(medico.id, fecha_inicio, fecha_fin)
    tiempos_existentes = Set.new(turnos_existentes.map { |turno| turno[:fecha_hora].to_i })

    encontrar_turnos_disponibles(fecha_inicio, fecha_fin, tiempos_existentes, duracion_turno).first(TURNOS_DISPONIBLES)
  end

  private

  def encontrar_turnos_disponibles(fecha_inicio, fecha_fin, tiempos_existentes, duracion)
    turnos_disponibles = []

    (fecha_inicio...fecha_fin).each do |fecha|
      next unless dia_laboral?(fecha)

      turnos_disponibles.concat(buscar_turnos_para_dia(fecha, duracion, tiempos_existentes))
    end

    turnos_disponibles.first(TURNOS_DISPONIBLES)
  end

  def buscar_turnos_para_dia(fecha, duracion, tiempos_existentes)
    inicio_jornada, fin_jornada = calcular_jornada(fecha)
    hora_actual = calcular_hora_inicio(fecha, inicio_jornada)
    ultimo_turno = fin_jornada - (duracion * 60)

    obtener_horarios_disponibles(hora_actual, ultimo_turno, duracion, tiempos_existentes)
  end

  def obtener_horarios_disponibles(hora_inicio, hora_fin, duracion, tiempos_existentes)
    huecos = []
    current = hora_inicio

    while current <= hora_fin
      huecos << current unless tiempos_existentes.include?(current.to_i)
      current += duracion * 60
    end

    huecos
  end

  def dia_laboral?(fecha)
    (1..5).cover?(fecha.wday)
  end

  def calcular_jornada(fecha)
    [
      Time.local(fecha.year, fecha.month, fecha.day, 8, 0, 0),
      Time.local(fecha.year, fecha.month, fecha.day, 18, 0, 0)
    ]
  end

  def calcular_hora_inicio(fecha, inicio_jornada)
    fecha == Date.today ? [Time.now, inicio_jornada].max : inicio_jornada
  end
end
