require_relative '../proveedor_feriados_interfaz'
require 'faraday'

class ProveedorFeriados < ProveedorFeriadosInterfaz
  def feriados(anio)
    url = "#{ENV['FERIADOS_URL']}/#{anio}"
    connection = Faraday::Connection.new url
    response = connection.get
    JSON.parse(response.body)
  end
end
