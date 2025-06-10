# language: es
Característica: Modificar estado de un turno

Antecedentes:
  Dado el paciente "usuario@prueba.com" registrado
  Y la especialidad "Traumatologia" dada de alta
  Y la especialidad "Dermatologia" dada de alta
  Y el médico "Juan Perez" de la especialidad "Traumatologia" con matricula "ABC123" dado de alta
  Y el médico "Nicolas Sanchez" de la especialidad "Dermatologia" con matricula "DEF456" dado de alta

@wip
Escenario: US-26.1 Marcar como cancelado un turno que aún no pasó
Dado hay un turno en el futuro
Y tiene estado "Pendiente"
Y el hospital intenta pasar a "Cancelado" el turno
Entonces el turno queda con estado "Cancelado"
Y recibo un mensaje "Turno actualizado: estado cancelado"

@wip
Escenario: US-26.2 Marcar como ausente un turno que ya pasó
Dado hay un turno ya pasado
Y tiene estado "Pendiente"
Y el hospital intenta pasar a "Ausente" el turno
Entonces el turno queda con estado "Ausente"
Y recibo un mensaje "Turno actualizado: estado ausente"

@wip
Escenario: US-26.3 Marcar como asistido un turno que ya pasó
Dado hay un turno ya pasado
Y tiene estado "Pendiente"
Y el hospital intenta pasar a "Asistido" el turno
Entonces el turno queda con estado "Asistido"
Y recibo un mensaje "Turno actualizado: estado asistido"

@wip
Escenario: US-26.4 - Marcar como cancelado un turno que ya pasó es invalido
Dado hay un turno ya pasado
Y tiene estado "Pendiente"
Y el hospital intenta pasar a "Cancelado" el turno
Entonces el turno queda con estado "Pendiente"
Y recibo un mensaje "no se puede cancelar un turno ya pasado"

@wip
Escenario: US-26.5 - Marcar como asistido un turno que aún no pasó es invalido
Dado hay un turno en el futuro
Y tiene estado "Pendiente"
Y el hospital intenta pasar a "Asistio" el turno
Entonces el turno queda con estado "Pendiente"
Y recibo un mensaje "no se puede marcar como asistido un turno en el futuro"

@wip
Escenario: US-26.6 Marcar como ausente un turno que aún no paso es invalido
Dado hay un turno en el futuro
Y tiene estado "Pendiente"
Y el hospital intenta pasar a "Ausente" el turno
Entonces el turno queda con estado "Pendiente"
Y recibo un mensaje "no se puede marcar como ausente un turno en el futuro"

@wip
Escenario: US-26.7 Intentar cambiar el estado de un turno con estado cancelado es invalido
Dado hay un turno en el futuro
Y tiene estado "Pendiente"
Y el hospital intenta pasar a "Ausente" el turno
Entonces el turno queda con estado "Cancelado"
Y recibo un mensaje "no se puede cambiar el estado de un turno que no este pendiente"

@wip
Escenario: US-26.8  Intentar cambiar el estado de un turno con estado ausente es invalido
Dado hay un turno ya pasado
Y tiene estado "Ausente"
Y el hospital intenta pasar a "Cancelado" el turno
Entonces el turno queda con estado "Ausente"
Y recibo un mensaje "no se puede cambiar el estado de un turno que no este pendiente"

@wip
Escenario: US-26.9  Intentar cambiar el estado de un turno con estado asistió es invalido
Dado hay un turno ya pasado
Y tiene estado "Asistido"
Y el hospital intenta pasar a "Cancelado" el turno
Entonces el turno queda con estado "Asistido"
Y recibo un mensaje "no se puede cambiar el estado de un turno que no este pendiente"

@wip
Escenario: US-26.10 Intentar cambiar el estado de un turno que no tiene estado pendiente es invalido
Dado hay un turno en el futuro
Y tiene estado "Pendiente"
Y el hospital intenta pasar a "Ausente" el turno
Entonces el turno queda con estado "Cancelado"
Y recibo un mensaje "no se puede cambiar el estado de un turno que no este pendiente"
