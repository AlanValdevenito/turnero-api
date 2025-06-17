# language: es
@wip
Característica: Autenticación por API KEY en la API

  Escenario: US-12.1 Acceso permitido con API KEY válida
    Cuando envío una request a la API incluyendo una API KEY válida en el header
    Entonces la API responde con la información solicitada

  Escenario: US-12.2 Acceso denegado con API KEY inválida
    Cuando envío una request a la API incluyendo una API KEY inválida en el header
    Entonces la API responde con un mensaje de error de autenticación

  Escenario: US-12.3 Acceso denegado sin API KEY
    Cuando envío una request a la API sin incluir una API KEY en el header
    Entonces la API responde con un mensaje de error de autenticación

