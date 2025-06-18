get '/usuarios' do
  logger.debug('GET /usuarios')
  usuarios = turnero.usuarios
  respuesta = []
  usuarios.map { |u| respuesta << { email: u.email, id: u.id } }
  status 200
  json(respuesta)
end

get '/usuarios/:email' do
  logger.debug("GET /usuarios/:email: #{params}")
  email = params[:email]
  begin
    usuario = turnero.gestor_usuarios.buscar_usuario_por_email(email)
    status 200
    json({ id: usuario.id, email: usuario.email })
  rescue UsuarioNoEncontradoException
    status 404
    json({ error: 'Usuario no encontrado' })
  end
end

get '/usuarios/telegram/:telegram_id' do
  logger.debug("GET /usuarios/telegram/:telegram_id: #{params}")
  telegram_id = params[:telegram_id]
  begin
    usuario = turnero.usuario_registrado?(telegram_id)
    status 200
    json({ id: usuario.id, email: usuario.email, telegram_id: usuario.telegram_id })
  rescue UsuarioNoEncontradoException
    status 404
    json({ error: 'Usuario no encontrado' })
  end
end

post '/usuarios' do
  logger.debug("POST /usuarios: #{@params}")
  begin
    usuario = turnero.crear_usuario(@params[:email], @params[:telegram_id])
    status 201
    json({ id: usuario.id, email: usuario.email, telegram_id: usuario.telegram_id, message: 'El paciente se registró existosamente' })
  rescue EmailEnUsoException
    status 400
    json({ error: 'El email ingresado ya está en uso' })
  rescue TelegramIdEnUsoException
    status 400
    json({ error: 'El paciente ya se encuentra registrado' })
  rescue EmailObligatorioException
    status 400
    json({ error: 'El email es obligatorio' })
  end
end

delete '/pacientes/:email' do
  logger.debug("DELETE /pacientes/:email: #{@params}")
  begin
    turnero.eliminar_usuario_por_email(@params[:email])
    status 200
    json({ message: 'paciente eliminado con sus turnos correspondientes' })
  rescue UsuarioNoEncontradoException
    status 404
    json({ message: "Paciente con email #{@params[:email]} inexistente" })
  end
end
