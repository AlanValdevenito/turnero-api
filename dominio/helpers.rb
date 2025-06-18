def normalizar_texto(texto)
  texto = texto.to_s.downcase

  acentos = {
    'á' => 'a', 'é' => 'e', 'í' => 'i', 'ó' => 'o', 'ú' => 'u'
  }

  acentos.each do |con_acento, sin_acento|
    texto = texto.gsub(con_acento, sin_acento)
  end

  texto
end
