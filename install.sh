#!/bin/bash
set -e

echo "=== INSTALL START ==="

# =========================
# Laravel directories
# =========================
mkdir -p bootstrap/cache \
         storage/framework/cache \
         storage/framework/sessions \
         storage/framework/views

chown -R www-data:www-data bootstrap storage || true
chmod -R ug+rwx bootstrap storage || true

# =========================
# ENV first
# =========================
cp .env.example .env || true

# =========================
# Composer
# =========================
composer install \
    --no-interaction \
    --optimize-autoloader

# =========================
# App key
# =========================
php artisan key:generate || true

# =========================
# Frontend (PRODUCTION)
# =========================
npm install --legacy-peer-deps --no-audit
npm run build

# =========================
# Database config
# =========================
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=mysql/g' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env

echo "=== INSTALL DONE ==="
