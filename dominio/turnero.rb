require_relative '../dominio/excepciones/excepciones_registracion'

class Turnero
  def initialize(repositorio_usuarios, repositorio_medicos, repositorio_especialidades)
    @repositorio_usuarios = repositorio_usuarios
    @repositorio_medicos = repositorio_medicos
    @repositorio_especialidades = repositorio_especialidades
  end

  def crear_usuario(email, telegram_id = nil)
    raise EmailEnUsoException if buscar_usuario_por_email(email)
    raise TelegramIdEnUsoException if telegram_id && @repositorio_usuarios.buscar_por_telegram_id(telegram_id)

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

  def crear_medico(nombre, apellido, matricula, especialidad)
    medico = Medico.new(nombre, apellido, matricula, especialidad.to_i)
    @repositorio_medicos.save(medico)
  end

  def crear_especialidad(nombre, duracion_de_turnos)
    especialidad = Especialidad.new(nombre, duracion_de_turnos)
    @repositorio_especialidades.save(especialidad)
  end

  def buscar_usuario_por_email(email)
    @repositorio_usuarios.buscar_por_email(email)
  end
end
