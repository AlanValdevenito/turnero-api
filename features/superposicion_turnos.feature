# language: es
Característica: Superposición de turnos

  Antecedentes:
    Dado existe el paciente con email "usuario@prueba.com"
    Y la especialidad "Traumatologia" dada de alta cuya duracion de turnos es 10 minutos
    Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Traumatologia" dado de alta
    Y la especialidad "Cardiologia" dada de alta cuya duracion de turnos es 30 minutos
    Y el médico "Jose Sanchez" con matrícula "XYZ123" de la especialidad "Cardiologia" dado de alta
    Y la especialidad "Oncologia" dada de alta cuya duracion de turnos es 1 minutos
    Y el médico "Martin Vista" con matrícula "DEF789" de la especialidad "Oncologia" dado de alta

  Escenario: US-15.1 Reserva de turno fallida por superposicion
    Dado que para la fecha '2025-06-13' y hora '08:30' reserve un turno con el médico con matrícula "ABC123"
    Cuando quiero reservar otro turno para la fecha '2025-06-13' y hora '08:30' con el médico con matrícula "XYZ123"
    Entonces se muestra un error 409
    Y se muestra el mensaje de error "Ya existe un turno reservado en esa fecha y horario"
  @wip
  Escenario: US-15.2 Reserva de turno borde fallida por superposicion
    Dado que para la fecha '2025-06-13' y hora '08:30' reserve un turno con el médico con matrícula "XYZ123"
    Cuando quiero reservar otro turno para la fecha '2025-06-13' y hora '08:59' con el médico con matrícula "DEF789"
    Entonces se muestra un error 409
    Y se muestra el mensaje de error "Ya existe un turno reservado en esa fecha y horario"
  @wip
  Escenario: US-15.3 Reserva de turno borde exitosa
    Dado que para la fecha '2025-06-13' y hora '08:30' reserve un turno con el médico con matrícula "XYZ123"
    Cuando quiero reservar otro turno para la fecha '2025-06-13' y hora '09:00' con el médico con matrícula "DEF789"
    Entonces se muestra un exito 201
    Y se muestra el mensaje "El turno se reservó exitosamente"