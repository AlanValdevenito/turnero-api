# language: es
Característica: Reserva de turno por especialidad

  Antecedentes:
    Dado existe el paciente con email "usuario@prueba.com"
    Y la especialidad "Traumatologia" dada de alta
    Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Traumatologia" dado de alta
  @wip
  Escenario: US-2.1 Reserva de turno exitosa
    Dado que el usuario pide un turno por especialidad
    Entonces se muestra un listado de todas las especialidades con su con nombre
    Cuando el usuario selecciona la especialidad "Traumatologia"
    Entonces se muestra un listado de 1 médico de la especialidad "Traumatologia" con su nombre y apellido
    Cuando el usuario selecciona un medico
    Entonces se muestran los próximos 3 turnos disponibles del médico dentro de los próximos 2 meses
    Cuando el usuario selecciona el turno con el medico de matricula "ABC123"
    Entonces se muestra el mensaje de exito "Turno agendado exitosamente"
    Y se muestra la fecha, hora, medico y especialidad del turno reservado
