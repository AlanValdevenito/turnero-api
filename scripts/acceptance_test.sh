#/bin/bash

set -e

TEAM=$1
ENVIRONMENT=$2

API_URL="https://api.9521.com.ar/${TEAM}-${ENVIRONMENT}"

ESPECIALIDAD_NOMBRE="Testologia"
DURACION=60
LIMITE=3
API_KEY=$(grep 'API_KEY:' infra/${ENVIRONMENT}.secrets.yaml | awk '{print $2}' | base64 -d)

if [ -z "$API_KEY" ]; then
  echo "❌ No se pudo obtener la API_KEY del archivo de secretos"
  exit 1
fi

echo "🛠️  Creando especialidad de prueba..."
CREATE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL/especialidades" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: $API_KEY" \
  -d "{\"nombre\": \"${ESPECIALIDAD_NOMBRE}\", \"duracion_de_turnos\": ${DURACION}, \"limite_turnos_por_usuario\": ${LIMITE}}")

if [[ "$CREATE_RESPONSE" != "200" && "$CREATE_RESPONSE" != "201" ]]; then
  echo "❌ Error al crear especialidad (status: $CREATE_RESPONSE)"
  exit 1
fi

echo "🔍 Verificando que la especialidad fue creada..."
GET_RESPONSE=$(curl -s -X GET "$API_URL/especialidades" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: $API_KEY")

echo "$GET_RESPONSE" | grep "$ESPECIALIDAD_NOMBRE" > /dev/null

if [ $? -ne 0 ]; then
  echo "❌ No se encontró la especialidad en el GET"
  exit 1
fi

echo "🧹 Eliminando especialidad de prueba..."
DELETE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$API_URL/especialidades/${ESPECIALIDAD_NOMBRE}" \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: $API_KEY")

if [[ "$DELETE_RESPONSE" != "200" && "$DELETE_RESPONSE" != "204" ]]; then
  echo "⚠️  Advertencia: no se pudo eliminar la especialidad (status: $DELETE_RESPONSE)"
else
  echo "✅ Especialidad eliminada correctamente"
fi

echo "✅ Acceptance Test OK"
exit 0
