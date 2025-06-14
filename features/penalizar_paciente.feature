# language: es
@wip
Característica: Penalización temporal por bajo porcentaje de asistencia

#   Como hospital
#   Quiero penalizar el acceso a turnos a pacientes con bajo porcentaje de asistencia
#   Para incentivar el cumplimiento de los turnos

  Antecedentes:
    Dado un paciente con email "paciente@email.com" registrado

  Escenario: 11.1 Puede sacar turno si tiene buen porcentaje
    Dado que el paciente tuvo 5 turnos: 4 asistidos y 1 ausente #80%
    Cuando intenta reservar un nuevo turno
    Entonces puede hacerlo exitosamente

  Escenario: 11.2 Penalización al bajar del 80%
    Dado que el paciente tuvo 5 turnos: 2 asistidos, 1 cancelado y 2 ausentes #60%
    Cuando intenta reservar un nuevo turno
    Entonces debe mostrarse un mensaje de penalización
    Y no puede reservar turnos por los próximos 3 minutos

  Escenario: 11.3 Los turnos pendientes no deben afectar el porcentaje
    Dado que el paciente tuvo 4 turnos: 1 asistido, 1 cancelado, 1 ausente y 1 pendiente #66%
    Cuando intenta reservar un nuevo turno
    Entonces debe mostrarse un mensaje de penalización
    Y no puede reservar turnos por los próximos 3 minutos

  Escenario: 11.4 Fin de la penalización después del tiempo
    Dado que el paciente fue penalizado por bajo porcentaje
    Y han pasado 3 minutos desde su último intento
    Cuando intenta reservar un nuevo turno
    Entonces puede hacerlo exitosamente

  Escenario: 11.5 Penalización al empeorar el historial
    Dado que el paciente tuvo 3 turnos: 2 asistidos y 1 pendiente #100%
    Y saco un turno exitosamente
    Cuando el estado del turno pendiente se cambia a ausente #75%
    Y vuelve a intentar sacar un turno
    Entonces debe mostrarse un mensaje de penalización
    Y no puede reservar turnos por los próximos 3 minutos

  Escenario: 11.6 Penalización se mantiene al empeorar historial luego del tiempo
    Dado que el paciente tuvo 5 turnos: 1 asistido, 2 cancelados, 1 ausente y 1 pendiente #75%
    Y que el paciente fue penalizado por bajo porcentaje
    Y han pasado 3 minutos desde su último intento
    Cuando el estado del turno pendiente se cambia a ausente #60%
    Y vuelve a intentar sacar un turno
    Entonces debe mostrarse un mensaje de penalización
    Y no puede reservar turnos por los próximos 3 minutos adicionales




