#!/bin/sh
set -e

echo "Generating Prisma client..."
npx prisma generate --schema=./prisma/schema.prisma

if [ "$NODE_ENV" = "production" ]; then
  echo "Running prisma migrate deploy"
  npx prisma migrate deploy --schema=./prisma/schema.prisma || true
else
  echo "Running prisma migrate dev (non-blocking)"
  npx prisma migrate dev --name init --schema=./prisma/schema.prisma || true
fi

exec "$@"
