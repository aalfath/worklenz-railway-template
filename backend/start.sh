#!/bin/sh
# Loads the base schema on an empty database, applies pending migrations,
# then starts the Worklenz API. Any failure exits non-zero so Railway restarts it.
set -e
cd /app

: "${DB_HOST:?DB_HOST is not set}"
: "${DB_NAME:?DB_NAME is not set}"
: "${DB_USER:?DB_USER is not set}"
: "${SESSION_SECRET:?SESSION_SECRET is not set}"
: "${JWT_SECRET:?JWT_SECRET is not set}"
export DB_PORT="${DB_PORT:-5432}"
export SOCKET_IO_CORS="${SOCKET_IO_CORS:-$FRONTEND_URL}"
export SERVER_CORS="${SERVER_CORS:-$FRONTEND_URL}"

# Keep the V8 heap inside a small (0.5 GB) Railway plan unless the deployer overrides it.
case " ${NODE_OPTIONS:-} " in
  *max-old-space-size*) ;;
  *) export NODE_OPTIONS="${NODE_OPTIONS:-} --max-old-space-size=${WORKLENZ_HEAP_MB:-320}" ;;
esac

node /app/railway/init-db.js
echo "[railway] applying database migrations"
node scripts/migrate.js up --no-verbose
echo "[railway] starting Worklenz API on port ${PORT}"
exec node build/bin/www
