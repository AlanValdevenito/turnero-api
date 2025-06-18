# language: es
Característica: Modificación de una especialidad

  Antecedentes:
    Dado existe el paciente con email "usuario@prueba.com"
    Y existe la especialidad con nombre "Traumatologia", con límite de 3 turnos por usuario y con duracion por cada turno de 30 minutos
    Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Traumatologia" dado de alta

  Escenario: US-24.1 Modificación exitosa una especialidad
    Dado que actualizo la especialidad "Traumatologia" con un nuevo nombre "Traumatologia general" y con un nuevo limite de 5 turnos por usuarios
    Entonces la respuesta es 200
    Y se muestra la informacion actualizada donde el nombre es "Traumatologia general"
    Y el limite de turnos por usuarios es 5
    Y la duracion por cada turno es 30 minutos

  Escenario: US-24.2 Modificacion invalida por nombre inexistente
    Dado que actualizo la especialidad "Pediatria" con un nuevo nombre "Pediatria general" y con un nuevo limite de 5 turnos por usuarios
    Entonces la respuesta es 404
    Y se muestra el mensaje de error "Especialidad no encontrada"

  Escenario: US-24.3 Modificacion invalida por limite negativo
    Dado que actualizo la especialidad "Traumatologia" con un nuevo nombre "Traumatologia general" y con un nuevo limite de -3 turnos por usuarios
    Entonces la respuesta es 400
    Y se muestra el mensaje de error "El limite de turnos por usuario debe ser un entero positivo"

  Escenario: US-24.4 Modificacion invalida por limite no entero
    Dado que actualizo la especialidad "Traumatologia" con un nuevo nombre "Traumatologia general" y con un nuevo limite de "ABC" turnos por usuarios
    Entonces la respuesta es 400
    Y se muestra el mensaje de error "El limite de turnos por usuario debe ser un numero entero"
