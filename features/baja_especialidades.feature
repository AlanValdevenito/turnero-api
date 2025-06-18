# language: es
Característica: Baja de especialidades

    Antecedentes:
        Dado existe el paciente con email "usuario@prueba.com"
        Y la especialidad "Cardiologia" dada de alta
        Y el médico "Juan Perez" con matrícula "ABC123" de la especialidad "Cardiologia" dado de alta
        Y el otro médico "Juan Smith" con matrícula "TRA123" de la especialidad "Cardiologia" dado de alta

    Escenario: US-21.1 Dar de baja una especialidad sin medicos
    Dado que la especialidad tiene 0 medicos
    Cuando quiero dar de baja la especialidad
    Entonces se muestra el mensaje de exitoo "Especialidad eliminada con sus medicos y turnos correspondientes"
    Y no hay turnos correspondientes a la especialidad
    Y la especialidad ya no esta dada de alta

    Escenario: US-21.2 Dar de baja una especialidad con medicos
    Dado que la especialidad tiene dos medicos
    Cuando quiero dar de baja la especialidad
    Entonces se muestra el mensaje de exitoo "Especialidad eliminada con sus medicos y turnos correspondientes"
    Y no hay turnos correspondientes a la especialidad
    Y la especialidad ya no esta dada de alta
    Y los medicos de la especialidad ya no estan dados de alta

    Escenario: US-21.3 Dar de baja una especialidad que no existe
    Cuando quiero dar de baja una especialidad inexistente
    Entonces se devuelve el error 404
