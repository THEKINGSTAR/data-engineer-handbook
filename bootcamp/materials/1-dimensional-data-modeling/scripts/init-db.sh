#!/bin/bash
set -e

echo "Checking if database exists..."
DB_EXISTS=$(psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB'")

if [ "$DB_EXISTS" != "1" ]; then
  echo "Database does not exist. Restoring from data.dump..."
  pg_restore --clean --no-owner -U "$POSTGRES_USER" -d "$POSTGRES_DB" /docker-entrypoint-initdb.d/data.dump
else
  echo "Database already exists. Skipping restore."
fi
