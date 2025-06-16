# language: es
Característica: Restricción de turnos por paciente y especialidad

Antecedentes:
  Dado existe el paciente con email "usuario@prueba.com"
  Y existe el paciente con email "pepito@prueba.com"
  Y existe el paciente con email "pepe@prueba.com"

  Y la especialidad "Dermatologia" dada de alta con límite de 2 turnos
  Y la especialidad "Cardiologia" dada de alta con límite de 2 turnos
  Y la especialidad "Traumatologia" dada de alta con límite de 2 turnos
  Y la especialidad "Oncologia" dada de alta con límite de 2 turnos

  Y el médico "Ana Torres" con matrícula "DER123" de la especialidad "Dermatologia" dado de alta
  Y el médico "Carlos Mendez" con matrícula "CAR456" de la especialidad "Cardiologia" dado de alta
  Y el médico "Laura Gomez" con matrícula "TRA789" de la especialidad "Traumatologia" dado de alta
  Y el médico "Mario Santos" con matrícula "ONC012" de la especialidad "Oncologia" dado de alta

@wip
Escenario: US16.1 Solicitar un turno dentro del limite permitido
    Dado que el paciente con email "usuario@prueba.com" tiene 1 turno pendientes en la especialidad "Dermatologia"
    Y el limite de turnos en "Dermatologia" es de 2
    Cuando solicita un nuevo turno en "Dermatologia"
    Entonces el turno es creado exitosamente

@wip
Escenario: US16.2 Reservar un turno superando el limite
    Dado que el paciente con email "usuario@prueba.com" tiene 2 turnos pendientes en la especialidad "Dermatologia"
    Y el limite de turnos en "Dermatologia" es de 2
    Cuando solicita un nuevo turno en "Dermatologia"
    Entonces el sistema rechaza la solicitud con el mensaje "Ya alcanzaste el limite de turnos para esta especialidad"

@wip
Escenario: US16.3 Paciente tiene turnos en estados no pendientes y puede reservar uno nuevo
    Dado que el paciente con email "usuario@prueba.com" tiene 2 turnos en "Dermatologia"
    Y un turno tiene estado "Ausente" y el otro "Asistido"
    Y el limite de turnos en "Dermatologia" es de 2
    Cuando solicita un nuevo turno en "Dermatologia"
    Entonces el turno es creado exitosamente

@wip
Escenario: US16.4 Paciente cancela un turno y puede reservar uno nuevo
    Dado que el paciente con email "pepito@prueba.com" tiene 2 turnos pendientes en "Cardiologia"
    Y el limite de turnos en "Cardiologia" es de 2
    Y cancela un turno en "Cardiologia"
    Cuando solicita un nuevo turno en "Cardiologia"
    Entonces el turno es creado exitosamente

@wip
Escenario: US16.5 Paciente reserva turnos en diferentes especialidades
    Dado que el paciente con email "pepe@prueba.com" tiene 2 turnos pendientes en "Traumatologia"
    Y el limite de turnos en "Traumatologia" es de 2
    Cuando solicita un nuevo turno en "Oncologia"
    Entonces el turno es creado exitosamente
