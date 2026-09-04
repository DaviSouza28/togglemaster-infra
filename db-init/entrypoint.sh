#!/bin/sh

set -e

export AWS_DEFAULT_REGION="us-east-1"
export AWS_REGION="us-east-1"
export PGSSLMODE="require"

echo "Obtendo credenciais do AWS Secrets Manager..."

AUTH_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id "togglemaster/auth-db" \
  --query SecretString \
  --output text)

FLAG_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id "togglemaster/flag-db" \
  --query SecretString \
  --output text)

TARGETING_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id "togglemaster/targeting-db" \
  --query SecretString \
  --output text)


AUTH_DB_HOST=$(echo "$AUTH_SECRET" | jq -r '.host')
AUTH_DB_PASSWORD=$(echo "$AUTH_SECRET" | jq -r '.password')
AUTH_DB_NAME=$(echo "$AUTH_SECRET" | jq -r '.database')
AUTH_DB_USER=$(echo "$AUTH_SECRET" | jq -r '.username')
AUTH_DB_PORT=$(echo "$AUTH_SECRET" | jq -r '.port')

FLAG_DB_HOST=$(echo "$FLAG_SECRET" | jq -r '.host')
FLAG_DB_PASSWORD=$(echo "$FLAG_SECRET" | jq -r '.password')
FLAG_DB_NAME=$(echo "$FLAG_SECRET" | jq -r '.database')
FLAG_DB_USER=$(echo "$FLAG_SECRET" | jq -r '.username')
FLAG_DB_PORT=$(echo "$FLAG_SECRET" | jq -r '.port')

TARGETING_DB_HOST=$(echo "$TARGETING_SECRET" | jq -r '.host')
TARGETING_DB_PASSWORD=$(echo "$TARGETING_SECRET" | jq -r '.password')
TARGETING_DB_NAME=$(echo "$TARGETING_SECRET" | jq -r '.database')
TARGETING_DB_USER=$(echo "$TARGETING_SECRET" | jq -r '.username')
TARGETING_DB_PORT=$(echo "$TARGETING_SECRET" | jq -r '.port')


echo "Inicializando Auth DB..."

PGPASSWORD="$AUTH_DB_PASSWORD" psql \
  -h "$AUTH_DB_HOST" \
  -p "$AUTH_DB_PORT" \
  -U "$AUTH_DB_USER" \
  -d "$AUTH_DB_NAME" \
  -f /sql/auth/init.sql


echo "Inicializando Flag DB..."

PGPASSWORD="$FLAG_DB_PASSWORD" psql \
  -h "$FLAG_DB_HOST" \
  -p "$FLAG_DB_PORT" \
  -U "$FLAG_DB_USER" \
  -d "$FLAG_DB_NAME" \
  -f /sql/flag/init.sql


echo "Inicializando Targeting DB..."

PGPASSWORD="$TARGETING_DB_PASSWORD" psql \
  -h "$TARGETING_DB_HOST" \
  -p "$TARGETING_DB_PORT" \
  -U "$TARGETING_DB_USER" \
  -d "$TARGETING_DB_NAME" \
  -f /sql/targeting/init.sql


echo "Todos os bancos foram inicializados com sucesso."