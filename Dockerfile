FROM php:7-cli

ARG BUILD_DATE
ARG VERSION
LABEL build_version="RadPenguin version:- ${VERSION} Build-date:- ${BUILD_DATE}"

ENV TZ="America/Edmonton"
ENV LANG en_US.UTF-8
ENV LC_ALL C.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install dependencies.
RUN apt-get update -qq && \
  apt-get install -yqq \
    curl \
    git

# Set the timezone                    
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime

# Configure PHP
RUN apt-get update -qq && \
  apt-get -yqq install \
    libzip-dev && \
 docker-php-ext-install -j$(nproc) \
    bcmath \
    mysqli \
    zip

# Install Imagemagick
RUN apt-get update -qq && \
  apt-get install -yqq \
    imagemagick \
    libmagick++-dev && \
  pecl install imagick && \
  docker-php-ext-enable imagick

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
