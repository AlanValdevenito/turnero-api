# language: es
Característica: feriados

  Antecedentes:
    Dado existe el paciente con email "usuario@prueba.com"
    Y la especialidad "Cardiologia" dada de alta
    Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Cardiologia" dado de alta
  @wip
  Escenario: US-14.1 No se pueden asignar turnos el 16 de Junio
	Dado el usuario pide los turnos disponibles del médico con matrícula "ABC123" siendo "2025-06-16"
	Entonces se muestran los próximos 3 turnos disponibles del médico dentro de los próximos 2 meses
	Y no aparecen turnos disponibles para el dia de la consulta
