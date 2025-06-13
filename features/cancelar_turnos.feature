# language: es
Característica: Consultar los turnos asignados a un médico por su matrícula

Antecedentes:
    Dado existe el paciente con email "usuario@prueba.com"
      Y la especialidad "Cardiologia" dada de alta
      Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Cardiologia" dado de alta

    Escenario: US-4.1 Cancelar un turno con mas de 24hs de anticipacion
      Dado que para la fecha '2025-06-13' reserve 1 turno con el medico con matricula "ABC123" siendo hoy '2025-06-10'
      Y consulto mis turnos
      Cuando pido cancelar el turno
      Entonces devuelve el mensaje "Turno cancelado con exito"
    @wip
    Escenario: US-4.2 Cancelar un turno con menos de 24hs de anticipacion
      Dado que para la fecha '2025-06-13' reserve 1 turno con el medico con matricula "ABC123" siendo hoy '2025-06-12'
      Cuando pido cancelar el turno
      Entonces devuelve el mensaje "Turno cancelado con poca anticipacion, sera tomado como ausente"
    @wip
    Escenario: US-4.3 Cancelar un turno con un id que no existe
      Dado que para la fecha '2025-06-13' reserve 1 turno con el medico con matricula "ABC123" siendo hoy '2025-06-12'
      Cuando pido cancelar un turno con un id inexistente
      Entonces devuelve el mensaje de error "No puedes cancelar este turno"
    @wip
    Escenario: US-4.4 Cancelar un turno con un id de un turno que no me pertenece
      Dado que para la fecha '2025-06-13' reserve 1 turno con el medico con matricula "ABC123" siendo hoy '2025-06-12'
      Cuando pido cancelar el turno de otro paciente
      Entonces devuelve el mensaje de error "No puedes cancelar este turno"