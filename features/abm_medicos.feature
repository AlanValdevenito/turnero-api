# language: es
Característica: ABM de medicos
    @wip
    Escenario: US-18.1 Alta exitosa de un médico
        Dado el sistema no tiene registrado al médico "Michael Jordan" con matricula "23"
        Cuando doy de alta al médico "Michael Jordan" de "Traumatologia" con matricula "23"
        Entonces veo el mensaje "El médico fue dado de alta correctamente."
        Y el médico "Michael Jordan" está registrado en el sistema
