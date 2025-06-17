# language: es

Característica: Baja de medicos

Antecedentes:
  Dado existe el paciente con email "usuario@prueba.com"
  Dado la especialidad "Cardiologia" dada de alta
  Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Cardiologia" dado de alta

Escenario: US-20.1 Dar de baja un medico sin turnos
  Dado que el medico tiene 0 turnos
  Cuando quiero dar de baja al medico
  Entonces se muestra el mensaje de exitoo "Medico eliminado con sus turnos correspondientes"
  Y no hay turnos correspondientes al medico
  Y el medico ya no esta dado de alta

Escenario: US-20.2 Dar de baja un medico con turnos
  Dado que el medico tiene 2 turnos
  Cuando quiero dar de baja al medico
  Entonces se muestra el mensaje de exitoo "Medico eliminado con sus turnos correspondientes"
  Y no hay turnos correspondientes al medico
  Y el medico ya no esta dado de alta
@wip
Escenario: US-20.3 Dar de baja un medico que no existe
  Cuando quiero dar de baja un medico inexistente
  Entonces se devuelve el error 404
