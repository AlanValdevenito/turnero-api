# language: es
Característica: Modificar estado de un turno

@wip
Escenario US-26.1 Marcar como cancelado un turno que aún no pasó
Dado hay un turno en el futuro
Y tiene estado "pendiente"
Y el hospital intenta pasar a "cancelado" el turno
Entonces el turno queda con estado "cancelado"
Y recibo un mensaje "Turno actualizado: estado cancelado"

@wip
Escenario US-26.2 Marcar como ausente un turno que ya pasó
Dado hay un turno ya pasado
Y tiene estado "pendiente"
Y el hospital intenta pasar a "ausente" el turno
Entonces el turno queda con estado "ausente"
Y recibo un mensaje "Turno actualizado: estado ausente"

@wip
Escenario US-26.3 Marcar como asistido un turno que ya pasó
Dado hay un turno ya pasado
Y tiene estado "pendiente"
Y el hospital intenta pasar a "asistido" el turno
Entonces el turno queda con estado "asistido"
Y recibo un mensaje "Turno actualizado: estado asistido"

@wip
Escenario US-26.4 - Marcar como cancelado un turno que ya pasó es invalido
Dado hay un turno ya pasado
Y tiene estado "pendiente"
Y el hospital intenta pasar a "cancelado" el turno
Entonces el turno queda con estado "pendiente"
Y recibo un mensaje "no se puede cancelar un turno ya pasado"

@wip
Escenario US-26.5 - Marcar como asistido un turno que aún no pasó es invalido
Dado hay un turno en el futuro
Y tiene estado "pendiente"
Y el hospital intenta pasar a "asistio" el turno
Entonces el turno queda con estado "pendiente"
Y recibo un mensaje "no se puede marcar como asistido un turno en el futuro"

@wip
Escenario US-26.6 Marcar como ausente un turno que aún no paso es invalido
Dado hay un turno en el futuro
Y tiene estado "pendiente"
Y el hospital intenta pasar a "ausente" el turno
Entonces el turno queda con estado "pendiente"
Y recibo un mensaje "no se puede marcar como ausente un turno en el futuro"

@wip
Escenario US-26.7 Intentar cambiar el estado de un turno con estado cancelado es invalido
Dado hay un turno en el futuro
Y tiene estado "pendiente"
Y el hospital intenta pasar a "ausente" el turno
Entonces el turno queda con estado "cancelado"
Y recibo un mensaje "no se puede cambiar el estado de un turno que no este pendiente"

@wip
Escenario US-26.8  Intentar cambiar el estado de un turno con estado ausente es invalido
Dado hay un turno ya pasado
Y tiene estado "ausente"
Y el hospital intenta pasar a "cancelado" el turno
Entonces el turno queda con estado "ausente"
Y recibo un mensaje "no se puede cambiar el estado de un turno que no este pendiente"

@wip
Escenario US-26.9  Intentar cambiar el estado de un turno con estado asistió es invalido
Dado hay un turno ya pasado
Y tiene estado "asistido"
Y el hospital intenta pasar a "cancelado" el turno
Entonces el turno queda con estado "asistido"
Y recibo un mensaje "no se puede cambiar el estado de un turno que no este pendiente"

@wip
Escenario US-26.10 Intentar cambiar el estado de un turno que no tiene estado pendiente es invalido
Dado hay un turno en el futuro
Y tiene estado "pendiente"
Y el hospital intenta pasar a "ausente" el turno
Entonces el turno queda con estado "cancelado"
Y recibo un mensaje "no se puede cambiar el estado de un turno que no este pendiente"
