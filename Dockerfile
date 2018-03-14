FROM php:7.1-cli as builder
RUN curl -o installer.php https://getcomposer.org/installer && \
    php installer.php --filename=composer && \
  mv composer /usr/local/bin/composer && \
  apt-get update && \
  apt-get install -yq --no-install-recommends git zlib1g-dev openssh-client && \
  docker-php-ext-install -j$(nproc) zip && \
  useradd -ms /bin/bash php --uid 2000
COPY --chown=2000:2000 composer.* scripts /var/www/html/
USER 2000:2000
WORKDIR /var/www/html/
RUN composer install
COPY --chown=2000:2000 . /var/www/html/

FROM php:7.1-apache
RUN apt-get update && \
  apt-get install -yq --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev \
            libpng-dev libpq-dev libicu-dev libtidy-dev mysql-client freetype* sudo && \
  pecl install redis && \
  pecl install igbinary && \
  docker-php-ext-enable redis igbinary && \
  docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr --with-png-dir=/usr && \
  docker-php-ext-install -j$(nproc) gd iconv json intl opcache pdo pdo_mysql mbstring tidy zip && \
  a2enmod rewrite && \
  apt-mark manual libjpeg62-turbo libpq5 libtidy-0.99-0 libicu52 && \
  apt-get purge -y --auto-remove man libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libicu-dev libtidy-dev libpq-dev && \
  rm -rf /var/lib/apt/lists/* /var/lib/cache/*
COPY docker/configs/ /
COPY --from=builder /var/www/html/ /var/www/html/
RUN chown www-data /var/www/html/web/sites/default/files
