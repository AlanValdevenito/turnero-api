# language: es

Característica: Baja de pacientes

  Antecedentes:
      Dado existe el paciente con email "usuario@prueba.com"
      Dado la especialidad "Cardiologia" dada de alta
      Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Cardiologia" dado de alta
  @wip
  Escenario: US-22.1 Dar de baja un paciente sin turnos
    Dado que el paciente tiene 0 turnos
    Cuando quiero dar de baja al paciente
    Entonces se muestra el mensaje de exitoo "paciente eliminado con sus turnos correspondientes"
    Y no hay turnos correspondientes al paciente
    Y el paciente no esta dado de alta
  @wip
  Escenario: US-22.2 Dar de baja un paciente con turnos
    Dado que el paciente tiene 2 turnos
    Cuando quiero dar de baja al paciente
    Entonces se muestra el mensaje "paciente eliminado con sus turnos correspondientes"
    Y no hay turnos correspondientes al paciente
    Y el paciente no esta dado de alta
  @wip
  Escenario: US-22.3 Dar de baja un paciente que no existe
    Cuando quiero dar de baja un paciente inexistente
    Entonces se devuelve el error "404"