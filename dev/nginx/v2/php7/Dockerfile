FROM centos:latest
MAINTAINER Tinywan <756684177@qq.com>

ENV TZ "Asia/Shanghai"

#安装扩展包
RUN yum install -y epel-release

#安装依赖
RUN yum -y update && \
	yum install -y wget gcc automake autoconf libtool make gcc-c++ vixie-cron  \
	file openssl-devel sharutils zip  bash vim cyrus-sasl-devel libmemcached \
	libmemcached-devel libyaml libyaml-devel unzip libvpx-devel openssl-devel \
	ImageMagick-devel autoconf tar gcc libxml2-devel libmcrypt mcrypt mhash \
	libmcrypt-devel libxml2 libxml2-devel bzip2 bzip2-devel curl curl-devel \
	libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel bison \
	libtool-ltdl-devel net-tools

RUN yum install -y \
	git zlib zlib-devel glibc glibc-devel \
	glib2 glib2-devel \
	ncurses curl openssl-devel \
	gdbm-devel db4-devel libXpm-devel \
	libX11-devel gd-devel gmp-devel \
	readline-devel libxslt-devel \
	expat-devel xmlrpc-c xmlrpc-c-devel \
	libicu-devel  \
	yum clean all

RUN groupadd  www-data \
	&& useradd -g www-data www-data

#install php
RUN cd /tmp && \
	wget http://cn.php.net/distributions/php-7.2.13.tar.gz && \
	tar -zxvf php-7.2.13.tar.gz && \
	cd php-7.2.13 && \
	./configure \
	--prefix=/usr/local/php7 \
	--with-config-file-path=/usr/local/php7/etc   \
	--with-fpm-user=www-data \
	--with-fpm-group=www-data \
	--with-mysql-sock=/var/run/mysqld/mysqld.sock \
	--with-mysqli \
	--enable-fpm  \
	--enable-soap \
	--with-libxml-dir \ 
	--with-openssl \
	--with-mhash \
	--with-pcre-regex  \
	--with-zlib \
	--enable-bcmath \
	--with-iconv \
	--with-bz2 \
	--enable-calendar \
	--with-curl \
	--with-cdb \
	--enable-dom \
	--enable-exif \
	--enable-fileinfo \
	--enable-filter \
	--with-pcre-dir \
	--enable-ftp \
	--with-gd \
	--with-openssl-dir \
	--with-jpeg-dir \
	--with-png-dir \
	--with-zlib-dir \
	--with-freetype-dir \
	--enable-gd-jis-conv \
	--with-gettext \
	--with-gmp \
	--with-mhash \
	--enable-json \
	--enable-mbstring \
	--enable-mbregex \
	--enable-mbregex-backtrack \
	--with-libmbfl \
	--with-onig \
	--enable-pdo \
	--with-pdo-mysql \
	--with-zlib-dir  \
	--with-readline \
	--enable-session \
	--enable-shmop \
	--enable-simplexml \
	--enable-sockets \
	--enable-sysvmsg \
	--enable-sysvsem \
	--enable-sysvshm \
	--enable-wddx \
	--with-libxml-dir  \
	--with-xsl \
	--enable-zip \
	--enable-mysqlnd-compression-support \
	--with-pear \
	--enable-intl \
	--enable-pcntl \
	--enable-opcache && \
	make && make install

#config
RUN ln -sf /usr/local/php7/bin/php    /usr/local/bin/php && \
	ln -sf /usr/local/php7/bin/phpize /usr/local/bin/phpize && \
	ln -sf /usr/local/php7/bin/pecl   /usr/local/bin/pecl

RUN cp /tmp/php-7.2.13/php.ini-development /usr/local/php7/lib/php.ini && \
	cp /usr/local/php7/etc/php-fpm.conf.default /usr/local/php7/etc/php-fpm.conf && \
	cp /usr/local/php7/etc/php-fpm.d/www.conf.default /usr/local/php7/etc/php-fpm.d/www.conf


#配置php
RUN sed -i -e 's/listen = 127.0.0.1:9000/listen = 9000/' /usr/local/php7/etc/php-fpm.d/www.conf

#install swoole
#RUN pecl install swoole

#add extension

#安装composer.phar
RUN cd /tmp
RUN wget https://getcomposer.org/composer.phar composer.phar
ADD composer.phar /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer

EXPOSE 9000

#启动php
ENTRYPOINT ["/usr/local/php7/sbin/php-fpm", "-F", "-c", "/usr/local/php7/lib/php.ini"]