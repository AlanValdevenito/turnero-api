# language: es
Característica: Registro Pacientes

Escenario: US-17.1 Registro exitoso
    Dado el paciente no está registrado y el email "pepito@ejemplo.com" no está en uso
    Cuando se quiere registrar con el mail "pepito@ejemplo.com"
    Entonces se registra exitosamente con el mensaje "El paciente se registró existosamente"

Escenario: US-17.2 El email ya está registrado
    Dado el email "pepe@ejemplo.com" ya está en uso
    Cuando otro paciente se quiere registrar con el mail "pepe@ejemplo.com"
    Entonces se muestra un error con el mensaje "El email ingresado ya está en uso"

@wip
Escenario: US-17.3 El paciente ya está registrado con un id de telegram
    Dado el paciente ya está registrado con un id de telegram 1
    Cuando se quiere registrar con el mail "pepe@ejemplo.com"
    Entonces se muestra un error con el mensaje "El paciente ya se encuentra registrado"

@wip
Escenario: US-17.4 El paciente se intenta registrar sin indicar su email
    Dado el paciente no está registrado
    Cuando se quiere registrar sin especificar el mail
    Entonces se muestra un error con el mensaje "El email es obligatorio"
