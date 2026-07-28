#!/bin/sh
set -e

# Generate an app key if none is configured (needed for cookie/session crypto).
if [ -z "${APP_KEY}" ]; then
    php artisan key:generate --force
fi

# Ensure the upload + framework folders exist (storage may be a fresh volume).
mkdir -p storage/app/public/products storage/app/public/avatars \
    storage/app/public/banners storage/framework/sessions \
    storage/framework/views storage/framework/cache/data storage/logs

# Public symlink so uploaded images are served under /storage/...
# Remove any stale/broken link first (a committed link points at a dev path).
rm -f public/storage
php artisan storage:link

# Apply any pending migrations (safe to run on every deploy).
php artisan migrate --force

# Cache config for speed (env vars are already present at container start).
php artisan config:cache

# Serve on the port Railway assigns.
php artisan serve --host=0.0.0.0 --port="${PORT:-8080}"
