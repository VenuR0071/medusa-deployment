#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Checking for essential environment variables..."
# Perform basic checks for critical variables (add more if needed)
if [ -z "$DATABASE_URL" ]; then echo "Error: DATABASE_URL is not set. Cannot proceed."; exit 1; fi
if [ -z "$REDIS_URL" ]; then echo "Error: REDIS_URL is not set. Cannot proceed."; exit 1; fi
if [ -z "$JWT_SECRET" ]; then echo "Error: JWT_SECRET is not set. Cannot proceed."; exit 1; fi
if [ -z "$COOKIE_SECRET" ]; then echo "Error: COOKIE_SECRET is not set. Cannot proceed."; exit 1; fi
# Add checks for other variables your app *absolutely* needs to function

echo "Creating .env file for Medusa backend from container environment variables..."
# Write all necessary environment variables to /app/.env for Medusa to find
# This is crucial if Medusa's CLI or application explicitly loads from .env
cat <<EOF > /app/.env
NODE_ENV=$NODE_ENV
DATABASE_URL=$DATABASE_URL
REDIS_URL=$REDIS_URL
JWT_SECRET=$JWT_SECRET
COOKIE_SECRET=$COOKIE_SECRET
STORE_CORS=$STORE_CORS
ADMIN_CORS=$ADMIN_CORS
AUTH_CORS=$AUTH_CORS
S3_BUCKET=$S3_BUCKET
S3_REGION=$S3_REGION
# IMPORTANT: Add any other environment variables here that your Medusa app
# expects to read from a .env file (e.g., MinIO/S3 keys, Stripe keys, etc.)
# If they are set in your ECS Task Definition, they will be available as shell variables.
EOF

echo "Content of /app/.env (for debugging):"
cat /app/.env # For debugging, this will show the .env content in logs

echo "Starting database migrations with: yarn run medusa db:migrate"
yarn run medusa db:migrate

echo "Database migrations complete. Executing original command to start Medusa backend..."
# The .env file created above will remain for the main application process if it uses dotenv.
# If you don't want the .env file to persist, you could add 'rm /app/.env' here,
# but usually it's fine for the main app to also use it.
exec "$@"