require 'integration_helper'
Dir[File.join(__dir__, '../../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../dominio/excepciones', '*.rb')].each { |file| require file }
require_relative '../../dominio/gestores/gestor_medicos'

describe GestorMedicos do
  let(:repositorio_medicos) { instance_double('RepositorioMedicos') }
  let(:repositorio_turnos)  { instance_double('RepositorioTurnos') }
  let(:gestor) { described_class.new(repositorio_medicos, repositorio_turnos) }
  let(:medico) { instance_double('Medico', matricula: 'ABC123', id: 1) }

  it 'busca un medico por matricula' do
    medico = instance_double('Medico')
    allow(repositorio_medicos).to receive(:buscar_por_matricula).with('ABC123').and_return(medico)
    expect(gestor.buscar_medico_por_matricula('ABC123')).to eq(medico)
  end

  it 'elimina el medico cuando existe' do
    allow(repositorio_medicos).to receive(:buscar_por_matricula).with('ABC123').and_return(medico)
    allow(repositorio_turnos).to receive(:eliminar_por_medico).with(medico)

    expect(repositorio_medicos).to receive(:delete).with(medico)
    gestor.eliminar_medico_por_matricula('ABC123')
  end

  it 'elimina los turnos del medico antes de eliminarlo' do
    allow(repositorio_medicos).to receive(:buscar_por_matricula).with('ABC123').and_return(medico)

    expect(repositorio_turnos).to receive(:eliminar_por_medico).with(medico).ordered
    expect(repositorio_medicos).to receive(:delete).with(medico).ordered

    gestor.eliminar_medico_por_matricula('ABC123')
  end

  it 'lanza MedicoNoEncontradoException si el medico no existe' do
    allow(repositorio_medicos).to receive(:buscar_por_matricula).with('ABC123').and_return(nil)

    expect { gestor.eliminar_medico_por_matricula('ABC123') }.to raise_error(MedicoNoEncontradoException)
  end
end
