require_relative '../excepciones/medico_no_encontrado_exception'
Dir[File.join(__dir__, '../dominio/excepciones', '*.rb')].each { |file| require file }

class GestorMedicos
  def initialize(repositorio_medico, repositorio_turnos)
    @repositorio_medicos = repositorio_medico
    @repositorio_turnos = repositorio_turnos
  end

  def buscar_medico_por_matricula(matricula)
    medico = @repositorio_medicos.buscar_por_matricula(matricula)
    raise MedicoNoEncontradoException unless medico

    medico
  end

  def eliminar_medico_por_matricula(matricula)
    medico = @repositorio_medicos.buscar_por_matricula(matricula)
    raise MedicoNoEncontradoException unless medico

    @repositorio_turnos.eliminar_por_medico(medico)
    @repositorio_medicos.delete(medico)
  end
end
