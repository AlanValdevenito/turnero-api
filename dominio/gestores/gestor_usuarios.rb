require_relative '../excepciones/excepciones_registracion'
require_relative '../excepciones/usuario_no_encontrado_exception'

class GestorUsuarios
  def initialize(repositorio_usuarios)
    @repositorio_usuarios = repositorio_usuarios
  end

  def crear_usuario(email, telegram_id = nil)
    raise TelegramIdEnUsoException if telegram_id && @repositorio_usuarios.buscar_por_telegram_id(telegram_id)
    raise EmailEnUsoException if @repositorio_usuarios.buscar_por_email(email)

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

  def buscar_usuario_por_email(email)
    usuario = @repositorio_usuarios.buscar_por_email(email)
    raise UsuarioNoEncontradoException unless usuario

    usuario
  end

  def buscar_usuario_por_telegram_id(telegram_id)
    usuario = @repositorio_usuarios.buscar_por_telegram_id(telegram_id)
    raise UsuarioNoEncontradoException unless usuario

    usuario
  end
end
