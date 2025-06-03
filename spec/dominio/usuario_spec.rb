require 'spec_helper'
require_relative '../../dominio/usuario'

RSpec.describe Usuario do
  it 'lanza ArgumentError si el email es nil' do
    expect { described_class.new(nil) }.to raise_error(ArgumentError)
  end

  it 'lanza ArgumentError si el email es vacío' do
    expect { described_class.new('') }.to raise_error(ArgumentError)
  end

  it 'lanza ArgumentError si el email es solo espacios' do
    expect { described_class.new('   ') }.to raise_error(ArgumentError)
  end
end
