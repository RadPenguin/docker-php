FROM php:7-cli

ARG BUILD_DATE
ARG VERSION
LABEL build_version="RadPenguin version:- ${VERSION} Build-date:- ${BUILD_DATE}"

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL C.UTF-8
ENV TZ="America/Edmonton"

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV IMAGEMAGICK_VERSION=3.4.3

# Install dependencies.
RUN apt-get update -qq && \
  apt-get install -yqq \
    curl \
    git \
    unzip

# Set the timezone                    
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime

# Configure PHP
RUN apt-get update -qq && \
  apt-get -yqq install \
    libzip-dev && \
 docker-php-ext-install -j$(nproc) \
    bcmath \
    exif \
    mysqli \
    zip && \
  pecl install xdebug && \
  docker-php-ext-enable xdebug

RUN mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
ADD ./php.ini /usr/local/etc/php/conf.d/custom.ini

# Install ImageMagick
RUN apt-get update && apt-get install -y --no-install-recommends libmagickwand-dev imagemagick && \
  mkdir -p /usr/src/php/ext/imagick && \
  curl --location https://pecl.php.net/get/imagick-${IMAGEMAGICK_VERSION}.tgz | tar zx --strip-components=1 -C /usr/src/php/ext/imagick && \
  export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
  docker-php-ext-install imagick

# Install Composer
RUN curl --silent https://getcomposer.org/composer.phar -o /usr/local/bin/composer && \
  chmod 755 /usr/local/bin/composer

# Install Yarn
RUN apt-get update -qq && \
  apt-get install -yqq gnupg && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt update -qq && \
  apt install -yqq yarn

# Clean up
RUN apt-get clean && rm -rf \
  /tmp/* \
  /var/lib/apt/lists/* \
  /var/tmp/*
