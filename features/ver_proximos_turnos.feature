# language: es
Característica: Ver próximos turnos

Antecedentes:
  Dado el paciente "usuario@prueba.com" registrado
  Y la especialidad "Traumatologia" dada de alta
  Y la especialidad "Dermatologia" dada de alta
  Y el médico "Juan Perez" de la especialidad "Traumatologia" con matricula "ABC123" dado de alta
  Y el médico "Nicolas Sanchez" de la especialidad "Dermatologia" con matricula "DEF456" dado de alta

Escenario: US-5.1 Ver próximos turnos con 1 turno pendiente
  Dado la fecha actual es "2026-07-01"
  Y el paciente tiene 1 turno con estado "Pendiente" con el médico "Juan Perez" matricula "ABC123" de la especialidad "Traumatologia"
  Cuando solicito los proximos turnos del paciente
  Entonces recibo un listado de sus próximos turnos con 1 turno
  Y tiene al medico "Juan Perez" de la especialidad "Traumatologia"

Escenario: US-5.2 Ver próximos turnos con 1 turno pendiente y 1 turno cancelado
  Dado la fecha actual es "2026-07-01"
  Y el paciente tiene 1 turno con estado "Pendiente" con el médico "Juan Perez" matricula "ABC123" de la especialidad "Traumatologia"
  Y el paciente tiene 1 turno con estado "Cancelado" con el médico "Nicolas Sanchez" matricula "DEF456" de la especialidad "Dermatologia"
  Cuando solicito los proximos turnos del paciente
  Entonces recibo un listado de sus próximos turnos con 1 turno
  Y tiene al medico "Juan Perez" de la especialidad "Traumatologia"

@wip
Escenario: US-5.3 Ver próximos turnos con 0 turnos pendientes
  Dado la fecha actual es "2026-07-01"
  Y el paciente tiene 0 turnos
  Cuando solicito los próximos turnos del paciente
  Entonces recibo un mensaje de error "El paciente no tiene próximos turnos"

@wip
Escenario: US-5.4 Ver próximos turnos con 2 turnos pendientes
  Dado la fecha actual es "2026-07-01" 
  Y el paciente tiene 1 turno con estado "Pendiente" con el médico "Juan Perez" matricula "ABC123" de la especialidad "Traumatologia" para la fecha "2026-08-01"
  Y el paciente tiene 1 turno con estado "Pendiente" con el médico "Nicolas Sanchez" matricula "DFG567" de la especialidad "Dermatologia" para la fecha "2026-10-01"
  Cuando solicito los próximos turnos del paciente
  Entonces recibo un listado de sus próximos turnos con 2 turno
  Y tiene el turno para la fecha "2026-08-01" con el médico "Juan Perez" de la especialidad "Traumatologia"
  Y tiene el turno para la fecha "2026-10-01" con el médico "Nicolas Sanchez" de la especialidad "Dermatologia"



