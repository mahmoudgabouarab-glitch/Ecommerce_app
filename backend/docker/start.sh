#!/bin/sh
set -e

# Ensure the upload folders exist (they live on the mounted persistent volume).
mkdir -p storage/app/public/products storage/app/public/avatars

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
