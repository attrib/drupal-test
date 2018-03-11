FROM php:7.1-apache
RUN curl -o installer.php https://getcomposer.org/installer && \
    php installer.php --filename=composer && \
    mv composer /usr/local/bin/composer
RUN apt-get update
RUN apt-get install -yq git zlib1g-dev openssh-client
RUN docker-php-ext-install -j$(nproc) zip
RUN useradd -ms /bin/bash php --uid 2000
RUN apt-get install -yq libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev \
    libpng-dev libpq-dev libicu-dev libtidy-dev mysql-client freetype* sudo
RUN pecl install redis
RUN pecl install igbinary
RUN docker-php-ext-enable redis igbinary
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr --with-png-dir=/usr
RUN docker-php-ext-install -j$(nproc) gd iconv json intl opcache pdo pdo_mysql mbstring tidy zip
COPY docker/docker.ini /etc/php/conf.d/
COPY docker/000-default.conf /etc/apache2/sites-enabled/
RUN a2enmod rewrite
COPY . /var/www/html/
RUN chown 2000:2000 -R /var/www/html
USER 2000:2000
RUN composer install
USER root
