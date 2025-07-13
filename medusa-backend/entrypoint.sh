#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Checking for DATABASE_URL environment variable..."
if [ -z "$DATABASE_URL" ]; then
  echo "Error: DATABASE_URL environment variable is not set."
  exit 1
fi

echo "Starting database migrations with: yarn run medusa db:setup"
# The DATABASE_URL environment variable is automatically available here from the ECS Task Definition
yarn run medusa db:setup

echo "Database migrations complete. Executing original command to start Medusa backend..."
# Execute the original command (CMD in Dockerfile) passed to the entrypoint
exec "$@"