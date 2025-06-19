# language: es
Característica: ABM de especialidades
    Escenario: US-19.1 Alta exitosa de una especialidad
        Dado el sistema no tiene registrado a la especialidad "Oncologia"
        Cuando doy de alta a la especialidad "Oncologia"
        Entonces veo el mensaje "La especialidad fue dada de alta correctamente."
        Y la especialidad "Oncologia" está registrada en el sistema
