require 'spec_helper'
require 'webmock/rspec'
require_relative '../../dominio/adapters/proveedor_feriados'
require 'dotenv/load'

describe ProveedorFeriados do
  it 'proveedor feriados devuelve lista con todos los feriados del anio' do
    stub_request(:get, 'https://nolaborables.com.ar/api/v2/feriados/2025')
      .to_return(status: 200, body: '[{ "dia": 16, "mes": 6 }]', headers: {})
    feriados = described_class.new.feriados(2025)
    expect(feriados.first['dia']).to eq(16)
    expect(feriados.first['mes']).to eq(6)
  end
end
