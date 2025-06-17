require_relative '../excepciones/medico_no_encontrado_exception'
Dir[File.join(__dir__, '../dominio/excepciones', '*.rb')].each { |file| require file }

class GestorMedicos
  def initialize(repositorio_medico)
    @repositorio_medicos = repositorio_medico
  end

  def eliminar_medico_por_matricula(matricula)
    medico = @repositorio_medicos.buscar_por_matricula(matricula)
    @repositorio_medicos.delete(medico)
  end
end
