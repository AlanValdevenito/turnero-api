require_relative '../excepciones/medico_no_encontrado_exception'
Dir[File.join(__dir__, '../dominio/excepciones', '*.rb')].each { |file| require file }
require_relative '../helpers'

class GestorMedicos
  def initialize(repositorio_medico, repositorio_turnos)
    @repositorio_medicos = repositorio_medico
    @repositorio_turnos = repositorio_turnos
  end

  def buscar_medico_por_matricula(matricula)
    matricula_normalizada = normalizar_texto(matricula).upcase
    medico = @repositorio_medicos.buscar_por_matricula(matricula_normalizada)
    raise MedicoNoEncontradoException unless medico

    medico
  end

  def eliminar_medico_por_matricula(matricula)
    matricula_normalizada = normalizar_texto(matricula).upcase
    medico = @repositorio_medicos.buscar_por_matricula(matricula_normalizada)
    raise MedicoNoEncontradoException unless medico

    @repositorio_turnos.eliminar_por_medico(medico)
    @repositorio_medicos.delete(medico)
  end
end
