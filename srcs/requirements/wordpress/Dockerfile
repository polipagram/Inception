FROM debian:12

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    wget \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz --strip-components=1 \
    && rm latest.tar.gz

RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY tools/init.sh /usr/local/bin/init.sh
COPY conf/www.cnf /etc/php/8.2/fpm/pool.d/www.conf

RUN chmod +x /usr/local/bin/init.sh

ENTRYPOINT ["/usr/local/bin/init.sh"]