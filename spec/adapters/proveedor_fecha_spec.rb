require 'spec_helper'
require_relative '../../dominio/adapters/proveedor_fecha'

describe ProveedorFecha do
  let(:proveedor_fecha) { described_class.new }
  let(:fecha_real) { Time.utc(2025, 6, 13, 12, 0, 0) }
  let(:fecha_mock) { Time.utc(2025, 6, 13, 18, 30, 0) }

  it 'devuelve la hora mockeada si fue seteada' do
    allow(Time).to receive(:now).and_return(fecha_real)
    proveedor_fecha.setear_fecha_mock(fecha_mock)
    expect(proveedor_fecha.ahora).to eq(fecha_mock)
  end

  it 'cancela la hora mockeada' do
    allow(Time).to receive(:now).and_return(fecha_real)
    proveedor_fecha.setear_fecha_mock(fecha_mock)
    proveedor_fecha.cancelar_fecha_mock
    expect(proveedor_fecha.ahora).to eq(fecha_real.utc)
  end
end
