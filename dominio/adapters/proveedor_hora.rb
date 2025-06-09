class ProveedorHora
  def ahora
    Time.now
  end

  def construir_hora(anio, mes, dia, hora, min)
    Time.local(anio, mes, dia, hora, min, 0)
  end

  def formatear(time)
    time.strftime('%Y-%m-%d %H:%M:%S')
  end

  def time_to_date_time(time)
    DateTime.parse(time)
  end
end
