# language: es
Característica: Ver historial de turnos

  Antecedentes:
    Dado existe el paciente con email "usuario@prueba.com"
    Y la especialidad "Cardiología" dada de alta
    Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Cardiología" dado de alta

  Escenario: US-6.1 Ver historial de turnos con ningún turno
    Dado que nunca reserve un turno
    Cuando quiero ver mi historial de turnos
    Entonces se muestra el mensaje "El paciente no tiene turnos en su historial"

  Escenario: US-6.2 Ver historial de turnos con 1 turno ausente 
    Dado que para la fecha '2025-04-08' reserve 1 turno con el médico con matrícula "ABC123" siendo hoy '2025-04-09'
    Y no asisti al turno
    Cuando quiero ver mi historial de turnos
    Entonces puedo ver mi turno con el médico "Juan Perez" de la especialidad "Cardiología" con estado "Ausente"

  Escenario: US-6.3 Ver historial de turnos con 1 turno al que el paciente asistio
    Dado que para la fecha '2025-05-06' reserve 1 turno con el médico con matrícula "ABC123" siendo hoy '2025-05-07'
    Y asisti al turno
    Cuando quiero ver mi historial de turnos
    Entonces puedo ver mi turno con el médico "Juan Perez" de la especialidad "Cardiología" con estado "Asistido"

  Escenario: US-6.4 Ver historial de turnos con 1 turno cancelado
    Dado que para la fecha '2025-06-13' reserve 1 turno con el médico con matrícula "ABC123" siendo hoy '2025-06-10'
    Y cancele el turno
    Cuando quiero ver mi historial de turnos
    Entonces puedo ver mi turno con el médico "Juan Perez" de la especialidad "Cardiología" con estado "Cancelado"

  Escenario: US-6.5 Ver historial de turnos con más de 15 turnos
    Dado que reserve 20 turnos a los cuales asisti
    Cuando quiero ver mi historial de turnos
    Entonces puedo ver los 15 turnos que ya pasaron más cercanos a la fecha actual ordenados por fecha desde el mas reciente al mas antiguo
