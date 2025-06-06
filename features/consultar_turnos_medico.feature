# language: es
Característica: Consultar los turnos asignados a un médico por su matrícula

  Antecedentes:
    Dado existe el paciente con email "juan@mail.com"
    Y la especialidad "Cardiología" dada de alta
    Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Cardiología" dado de alta

  Escenario: US-30.1 Quiero ver los turnos de un medico que no tiene turnos
    Dado el médico con matrícula "ABC123" tiene 0 turnos
    Cuando consulto los turnos del médico con matrícula "ABC123"
    Entonces deberia ver una lista con 0 turnos

  Escenario: US-30.2 Quiero ver los turnos y sus detalles de un medico con 1 turno
    Dado el médico con matrícula "ABC123" tiene un turno "Pendiente" con el paciente "juan@mail.com" para la fecha "2025-06-10" durante el horario "10:00"
    Cuando consulto los turnos del médico con matrícula "ABC123"
    Entonces deberia ver una lista con 1 turnos
    Y deberia ver el id del turno
    Y deberia ver el estado "Pendiente", email del paciente "juan@mail.com", fecha "2025-06-10" y hora "10:00"
  @wip
  Escenario: US-30.3 Ver los turnos de un medico no dado de alta es invalido
   Dado el medico con matricula "XYZ999" no esta dado de alta 
   Cuando consulto los turnos del médico con matrícula "XYZ999"
   Entonces deberia ver un error 404
   Y el mensaje de error debe ser "Medico con matricula XYZ999 inexistente"
  @wip
  Escenario: US-30.4 - El médico tiene más de 20 turnos
    Dado que el médico con matrícula "ABC123" tiene 30 turnos
    Cuando consulto los turnos del médico con matrícula "ABC123"
    Entonces deberia ver una lista con 20 turnos
    Y en orden desde el más reciente al más antiguo
