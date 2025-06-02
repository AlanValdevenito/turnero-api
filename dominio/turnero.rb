require_relative '../dominio/excepciones/email_en_uso_exception'

class Turnero
  def initialize(repositorio_usuarios, repositorio_medicos)
    @repositorio_usuarios = repositorio_usuarios
    @repositorio_medicos = repositorio_medicos
  end

  def crear_usuario(email)
    raise EmailEnUsoException if buscar_usuario_por_email(email)

    usuario = Usuario.new(email)
    @repositorio_usuarios.save(usuario)
    usuario
  end

  def usuarios
    @repositorio_usuarios.all
  end

  def crear_medico(nombre, apellido, especialidad, matricula)
    medico = Medico.new(nombre, apellido, especialidad, matricula)
    @repositorio_medicos.save(medico)
  end

  def buscar_usuario_por_email(email)
    @repositorio_usuarios.buscar_por_email(email)
  end
end
