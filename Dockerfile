FROM php:7.4-apache
COPY . /var/www/html
WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libbz2-dev \
        libxslt-dev \
        libreadline-dev \
        libedit-dev \
        libldap2-dev \
        libxml2-dev \
        libssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) gd \
       mysqli \
       pdo_mysql

RUN pecl install redis-5.1.1 \
    && pecl install xdebug-2.8.1 \
    && docker-php-ext-enable redis xdebug

RUN docker-php-ext-install bz2
RUN docker-php-ext-install intl
RUN docker-php-ext-install calendar
RUN docker-php-ext-install shmop
RUN docker-php-ext-install xsl
RUN docker-php-ext-install gd
RUN docker-php-ext-install soap
RUN docker-php-ext-install sockets
RUN docker-php-ext-install sysvmsg
RUN docker-php-ext-install sysvsem
RUN docker-php-ext-install sysvshm
RUN docker-php-ext-install opcache
RUN docker-php-ext-install readline
RUN docker-php-ext-install gettext
RUN docker-php-ext-install exif

# Oracle instantclient
ADD instantclient-basic-linux.x64-19.9.0.0.0dbru.zip /tmp/instantclient-basic-linux.x64-19.9.0.0.0dbru.zip
ADD instantclient-sdk-linux.x64-19.9.0.0.0dbru.zip /tmp/instantclient-sdk-linux.x64-19.9.0.0.0dbru.zip
ADD instantclient-sqlplus-linux.x64-19.9.0.0.0dbru.zip /tmp/instantclient-sqlplus-linux.x64-19.9.0.0.0dbru.zip

RUN apt-get install -y unzip

RUN unzip /tmp/instantclient-basic-linux.x64-19.9.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-19.9.0.0.0dbru.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-19.9.0.0.0dbru.zip -d /usr/local/
RUN ln -sf /usr/local/instantclient_19_9 /usr/local/instantclient
RUN ln -sf /usr/local/instantclient/libclntsh.so.19.1 /usr/local/instantclient/libclntsh.so
RUN ln -sf /usr/local/instantclient/sqlplus /usr/bin/sqlplus

RUN apt-get install libaio-dev -y

ENV LD_LIBRARY_PATH /usr/local/instantclient_19_9/

# Install Oracle extensions
RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient_19_9,19.1 \
       && echo 'instantclient,/usr/local/instantclient/' | pecl install oci8 \
       && docker-php-ext-install \
               pdo_oci \
       && docker-php-ext-enable \
               oci8

# Instal LDAP
RUN \
    apt-get update && \
    apt-get install libldap2-dev -y && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

# install the ssl-cert package which will create a "snakeoil" keypair
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y ssl-cert \
    && rm -r /var/lib/apt/lists/*

# enable ssl module and enable the default-ssl site
RUN a2enmod ssl \
    && a2ensite default-ssl \
    && a2enmod rewrite

RUN rm /var/www/html/* -f

RUN echo 'max_execution_time = 800' >> /usr/local/etc/php/conf.d/docker-php-maxexectime.ini;
RUN echo "upload_max_filesize = 128M;" >> /usr/local/etc/php/conf.d/uploads.ini

RUN apt-get update
RUN apt-get install vim -y





