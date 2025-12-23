FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# System dependencies
# =========================
RUN apt update && apt install -y \
    apache2 \
    php \
    php-cli \
    php-xml \
    php-mbstring \
    php-curl \
    php-mysql \
    php-gd \
    npm \
    curl \
    unzip \
    bash \
    nano && \
    rm -rf /var/lib/apt/lists/*

# =========================
# Composer
# =========================
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

# =========================
# App directory
# =========================
WORKDIR /var/www/sosmed

COPY . .
COPY sosmed.conf /etc/apache2/sites-available/

RUN a2dissite 000-default.conf && a2ensite sosmed.conf

# =========================
# Permissions + install
# =========================
RUN chmod +x install.sh && bash install.sh

RUN chown -R www-data:www-data /var/www/sosmed && \
    chmod -R 755 /var/www/sosmed

EXPOSE 8000

# =========================
# Runtime (DB already up)
# =========================
CMD php artisan migrate --force && \
    php artisan db:seed --force && \
    php artisan serve --host=0.0.0.0 --port=8000
