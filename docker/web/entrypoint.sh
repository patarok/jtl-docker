#!/bin/sh
# Copy shop files to mounted volume if not already present
if [ -z "$(ls -A /var/www/html)" ]; then
    echo "Initializing JTL-Shop files..."
    cp -a /var/www/html-template/. /var/www/html/
    chown www-data:www-data /var/www/html -R
fi

exec docker-php-entrypoint apache2-foreground