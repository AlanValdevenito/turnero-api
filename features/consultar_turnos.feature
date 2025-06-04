# language: es
Característica: Consulta de turnos
  Antecedentes: 
    Dado hay 1 paciente registrado
    Y la especialidad "Traumatologia" dada de alta
    Y el medico "Perez" de "Traumatologia" dado de alta

  Escenario: US-7.1 Quiero ver los turnos de un paciente que nunca pidió turnos
    Dado el paciente tiene 0 turnos
    Cuando pido ver turnos del paciente
    Entonces debería ver una lista con 0 turnos
  @wip
  Escenario: US-7.2 Quiero ver los turnos y sus detalles de un paciente con 1 turno
    Dado el paciente tiene 1 turno "Pendiente" con el medico "Perez" de "Traumatología"
    Cuando pido ver turnos del paciente
    Entonces debería ver una lista con 1 turnos
    Y deberia tener el estado "Pendiente", medico "Perez" y especialidad "Traumatología"
  @wip
  Escenario: US-7.3 Quiero ver los turnos de un paciente con 3 turnos
    Dado el paciente tiene 3 turnos
    Cuando pido ver turnos del paciente
    Entonces debería ver una lista con 3 turnos
  @wip
  Escenario: US-7.4 Ver los turnos de un paciente no registrado es invalido
    Dado el paciente "paciente@ejemplo.com" no está registrado
    Cuando pido ver turnos del paciente "paciente@ejemplo.com"
    Entonces debería ver un error "404 Not Found" con un mensaje "Paciente con email paciente@ejemplo.com inexistente"
  @wip
  Escenario: US-7.5 Quiero ver los turnos de un paciente con más de 20 turnos
    Dado el paciente tiene 30 turnos
    Cuando pido ver turnos del paciente
    Entonces debería ver una lista con 20 turnos
