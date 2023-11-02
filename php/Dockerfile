FROM php:8.2-fpm-alpine

# Enable some docker extensionsf or PHP...
RUN docker-php-ext-install pdo pdo_mysql

# here we're going to be wanting to do some stuff with composer and ensuring that those particular things are returning
# (composer.lock/vendor ... etc). as these particular files are going to be needed for displaying them in the necessary
# projects.

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
