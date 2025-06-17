require 'spec_helper'
require_relative '../../dominio/adapters/proveedor_hora'

describe ProveedorHora do
  let(:proveedor_hora) { described_class.new }

  it 'devuelve la hora mockeada si fue seteada' do
    hora_mock = Time.utc(2025, 6, 13, 18, 30, 0)
    proveedor_hora.setear_hora_mock(hora_mock)
    expect(proveedor_hora.ahora).to eq(hora_mock)
  end
end
