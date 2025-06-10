class RegistroUsuario
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
    @repositorio_usuarios.buscar_por_email(email)
  end

  def buscar_usuario_por_telegram_id(telegram_id)
    @repositorio_usuarios.buscar_por_telegram_id(telegram_id)
  end
end
