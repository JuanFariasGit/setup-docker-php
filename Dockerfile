FROM debian:latest

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    ca-certificates \
    lsb-release \
    apt-transport-https \
    unzip \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install --lts

ENV NODE_VERSION lts
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN apt-get update && apt-get install -y php8.3 php8.3-cli php8.3-fpm php8.3-mysql php8.3-mbstring php8.3-xml php8.3-curl php8.3-zip php8.3-gd

RUN apt-get update && apt-get install -y php7.4 php7.4-cli php7.4-fpm php7.4-mysql php7.4-mbstring php7.4-xml php7.4-curl php7.4-zip php7.4-json php7.4-gd

RUN sed -i 's/listen = \/run\/php\/php8.3-fpm.sock/listen = 9000/' /etc/php/8.3/fpm/pool.d/www.conf
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9001/' /etc/php/7.4/fpm/pool.d/www.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer global require laravel/installer

WORKDIR /var/www

ENV PHP_83_VERSION=8.3
ENV PHP_74_VERSION=7.4

EXPOSE 9000 9001

CMD ["sh", "-c", "php-fpm8.3 -F & php-fpm7.4 -F"]
