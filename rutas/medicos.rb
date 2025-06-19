Dir[File.join(__dir__, '../dominio/excepciones', '*.rb')].each { |file| require file }

post '/medicos' do
  logger.debug("POST /medicos: #{@params}")
  medico = turnero.crear_medico(@params[:nombre], @params[:apellido], @params[:matricula], @params[:especialidad])
  status 200
  { message: 'El médico fue dado de alta correctamente.', id: medico.id }.to_json
rescue MatriculaDuplicadaException
  status 409
  { error: 'La matricula corresponde a un medico existente' }.to_json
rescue EspecialidadNoEncontradaException
  status 422
  { error: 'La especialidad no existe' }.to_json
end

get '/medicos' do
  logger.debug('GET /medicos')
  medicos = turnero.medicos
  respuesta = []
  medicos.map { |m| respuesta << { nombre: m.nombre, apellido: m.apellido, matricula: m.matricula, especialidad: m.especialidad.nombre } }
  status 200
  json(respuesta)
end

delete '/medicos/:matricula' do
  logger.debug("DELETE /medicos/:matricula : #{@params}")
  begin
    turnero.eliminar_medico_por_matricula(@params[:matricula])
    status 200
    { message: 'Medico eliminado con sus turnos correspondientes' }.to_json
  rescue MedicoNoEncontradoException
    status 404
    { message: "Medico con matricula #{@params[:matricula]} inexistente" }.to_json
  end
end
