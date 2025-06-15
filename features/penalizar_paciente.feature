# language: es
Característica: Penalización temporal por bajo porcentaje de asistencia

#   Como hospital
#   Quiero penalizar el acceso a turnos a pacientes con bajo porcentaje de asistencia
#   Para incentivar el cumplimiento de los turnos

  Antecedentes:
    Dado un paciente con email "paciente@email.com" registrado
    Y la especialidad "Traumatologia" dada de alta
    Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Traumatologia" dado de alta
    Y la fecha y hora actual es "2025-06-01" "10:00"

  Escenario: 11.1 Puede sacar turno si tiene buen porcentaje
    Dado que el paciente tuvo 5 turnos: 4 Asistido y 1 Ausente #80%
    Cuando intenta reservar un nuevo turno
    Entonces puede hacerlo exitosamente

  Escenario: 11.2 Penalización al bajar del 80%
    Dado que el paciente tuvo 5 turnos: 2 Asistido, 1 Cancelado y 2 Ausente #60%
    Cuando intenta reservar un nuevo turno
    Entonces debe mostrarse un mensaje de penalización
    Y no puede reservar turnos por los próximos 3 minutos

  Escenario: 11.3 Los turnos Pendientes no deben afectar el porcentaje
    Dado que el paciente tuvo 4 turnos: 1 Asistido, 1 Cancelado, 1 Ausente y 1 Pendiente #66%
    Cuando intenta reservar un nuevo turno
    Entonces debe mostrarse un mensaje de penalización
    Y no puede reservar turnos por los próximos 3 minutos

  Escenario: 11.4 Fin de la penalización después del tiempo
    Dado que el paciente fue penalizado por bajo porcentaje
    Y han pasado 3 minutos desde su último intento
    Cuando intenta reservar un nuevo turno
    Entonces puede hacerlo exitosamente

  Escenario: 11.5 Penalización al empeorar el historial
    Dado que el paciente tuvo 3 turnos: 2 Asistido y 1 Pendiente #100%
    Y saco un turno exitosamente
    Cuando el estado del turno Pendiente se cambia a Ausente
    Y intenta reservar un nuevo turno
    Entonces debe mostrarse un mensaje de penalización
    Y no puede reservar turnos por los próximos 3 minutos

  @wip
  Escenario: 11.6 Penalización se mantiene al empeorar historial luego del tiempo
    Dado que el paciente tuvo 5 turnos: 1 Asistido, 2 Cancelado, 1 Ausente y 1 Pendiente #75%
    Y que el paciente fue penalizado por bajo porcentaje
    Y han pasado 3 minutos desde su último intento
    Cuando el estado del turno Pendiente se cambia a Ausente
    Y intenta reservar un nuevo turno
    Entonces debe mostrarse un mensaje de penalización
    Y no puede reservar turnos por los próximos 3 minutos




