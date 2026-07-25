# ShopSphere API — container image for Railway (or any Docker host).
FROM php:8.2-cli

# System deps + PHP extensions Laravel needs.
RUN apt-get update && apt-get install -y --no-install-recommends \
        git unzip libzip-dev libpng-dev libjpeg-dev libonig-dev \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql mbstring bcmath zip gd exif \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist \
    && chmod -R 775 storage bootstrap/cache \
    && chmod +x docker/start.sh

# Railway provides $PORT at runtime; the start script binds to it.
CMD ["sh", "docker/start.sh"]
