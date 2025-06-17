require 'integration_helper'
Dir[File.join(__dir__, '../../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../dominio/excepciones', '*.rb')].each { |file| require file }
require_relative '../../dominio/gestores/gestor_medicos'

describe GestorMedicos do
  let(:repositorio_medicos) { instance_double('RepositorioMedicos') }
  let(:repositorio_turnos)  { instance_double('RepositorioTurnos') }
  let(:gestor) { described_class.new(repositorio_medicos) }
  let(:medico) { instance_double('Medico', matricula: 'ABC123') }

  it 'elimina el medico cuando existe' do
    allow(repositorio_medicos).to receive(:buscar_por_matricula).with('ABC123').and_return(medico)
    expect(repositorio_medicos).to receive(:delete).with(medico)
    gestor.eliminar_medico_por_matricula('ABC123')
  end
end
