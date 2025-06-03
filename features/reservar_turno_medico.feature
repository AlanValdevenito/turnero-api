# language: es
Característica: Reserva de un turno

@wip
Escenario: US-3.1 Reserva de turno exitosa
    Dado el usuario pide un turno
    Entonces se retorna un listado numerado de 7 médicos con nombre, apellido, matricula, especialidad
    Cuando el usuario selecciona un médico de la lista
    Entonces se retornan los próximos 3 turnos disponibles del médico dentro de los próximos 2 meses
    Cuando el usuario selecciona un turno
    Entonces se reserva exitosamente con el mensaje "El turno se reservó exitosamente"
    Y se muestra la información del turno: fecha y médico

@wip
Escenario: US-3.2 Reserva de turno no exitosa por selección inválida
    Dado el usuario pide un turno
    Entonces se retorna un listado numerado de 7 médicos con nombre, apellido, matricula, especialidad
    Cuando el usuario selecciona un médico que no se encuentra en la lista
    Entonces se muestra un error con el mensaje "La opción seleccionada no es válida"

@wip
Escenario: US-3.3 Reserva no exitosa por falta de turnos disponibles
    Dado el usuario pide un turno
    Entonces se muestra un listado numerado de 7 médicos con nombre, apellido, matricula, especialidad
    Cuando el usuario selecciona un médico de la lista
    Y el médico no tiene turnos disponibles en los próximos 2 meses
    Entonces se muestra un error con el mensaje "No hay turnos disponibles para este médico"
