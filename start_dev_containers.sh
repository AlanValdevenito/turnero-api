on_message '/historial-turnos' do |bot, message|
  turnero = Turnero.new(ProveedorTurnero.new(ENV['API_URL']))

  begin
    turnos = turnero.historial_turnos(message.from.id)
    #turnero.usuario_registrado?(message.from.id)
    respuesta = "📋 *Historial de Turnos:*\n\n"
    turnos.each_with_index do |turno, i|
      respuesta += "#{i + 1}. 🗓️ *Fecha:* #{turno.fecha} - ⏰ *Hora:* #{turno.hora}\n"
      respuesta += "   👨‍⚕️ *Médico:* #{turno.medico.nombre} #{turno.medico.apellido}\n"
      respuesta += "   🏥 *Especialidad:* #{turno.especialidad}\n\n"
    end

    bot.api.send_message(chat_id: message.chat.id, text: respuesta, parse_mode: 'Markdown')
  end
  rescue NoHayTurnosEnTuHistorialException
    bot.api.send_message(chat_id: message.chat.id, text: "No tenés turnos en tu historial.")
  end
end
