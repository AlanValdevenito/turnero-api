require 'integration_helper'
require_relative '../../dominio/medico'
require_relative '../../persistencia/repositorio_medicos'

describe RepositorioMedicos do
  it 'deberia guardar y asignar id si el medico es nuevo' do
    traumatologia = 1
    medico = Medico.new('Michael', 'Jordan', '112324', traumatologia)
    described_class.new.save(medico)
    expect(medico.id).not_to be_nil
  end
end
