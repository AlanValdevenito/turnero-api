require 'spec_helper'
require_relative '../../dominio/adapters/proveedor_hora'

describe ProveedorHora do
  let(:proveedor_hora) { described_class.new }
  let(:hora_real) { Time.utc(2025, 6, 13, 12, 0, 0) }
  let(:hora_mock) { Time.utc(2025, 6, 13, 18, 30, 0) }

  it 'devuelve la hora mockeada si fue seteada' do
    allow(Time).to receive(:now).and_return(hora_real)
    proveedor_hora.setear_hora_mock(hora_mock)
    expect(proveedor_hora.ahora).to eq(hora_mock)
  end

  it 'cancela la hora mockeada' do
    allow(Time).to receive(:now).and_return(hora_real)
    proveedor_hora.setear_hora_mock(hora_mock)
    proveedor_hora.cancelar_hora_mock
    expect(proveedor_hora.ahora).to eq(hora_real.utc)
  end
end
