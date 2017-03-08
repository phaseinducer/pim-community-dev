FROM ubuntu:16.04

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive" \
    COMPOSER_ALLOW_SUPERUSER=1

EXPOSE 80
WORKDIR /app


RUN apt-get update -q && \
    apt-get install -qy software-properties-common language-pack-en-base && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update -q && \
    apt-get install --no-install-recommends -qy \
        ca-certificates \
        cron \
        curl \
        nano \
        git \
        nginx \
        php5.6 \
        php5.6-cli \
        php5.6-bcmath \
        php5.6-common \
        php5.6-curl \
        php5.6-dom \
        php5.6-gd \
        php5.6-fpm \
        php5.6-iconv \
        php5.6-intl \
        php5.6-json \
        php5.6-mbstring \
        php5.6-mcrypt \
        php5.6-mysql \
        php5.6-pdo \
        php5.6-dom \
        php5.6-xml \
        php5.6-zip \
        php5.6-apc \
        php5.6-mongo \
        supervisor \
        tzdata \
        wget && \

    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    phpdismod xdebug && \

    echo "Etc/UTC" > /etc/timezone && \

    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \

    mkdir /run/php


COPY docker/dev/cli/php.ini /etc/php/5.6/cli/conf.d/50-setting.ini
COPY docker/dev/php.ini /etc/php/5.6/fpm/conf.d/50-setting.ini
COPY docker/dev/pool.conf /etc/php/5.6/fpm/pool.d/www.conf
COPY docker/dev/nginx.conf /etc/nginx/nginx.conf
COPY docker/dev/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
