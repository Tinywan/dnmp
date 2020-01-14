#!/bin/bash

export MC="-j$(nproc)"
# debug:0; info:1; warn:2; error:3
LOG_LEVEL=0

function record_log() {
    local type=$1
    local content=$2
    case $type in
    debug)
        [[ $LOG_LEVEL -le 0 ]] && echo -e "\033[34m${content}\033[0m"
        ;;
    info)
        [[ $LOG_LEVEL -le 1 ]] && echo -e "\033[32m${content}\033[0m"
        ;;
    warn)
        [[ $LOG_LEVEL -le 2 ]] && echo -e "\033[33m${content}\033[0m"
        ;;
    error)
        [[ $LOG_LEVEL -le 3 ]] && echo -e "\033[31m${content}\033[0m"
        ;;
    esac
}

record_log info ""
record_log info "===================================================================================="
record_log info "Install extensions from   : install.sh"
record_log info "PHP version               : ${PHP_VERSION}"
record_log info "Extra Extensions          : ${PHP_EXTENSIONS}"
record_log info "Multicore Compilation     : ${MC}"
record_log info "Container package url     : ${CONTAINER_PACKAGE_URL}"
record_log info "Work directory            : ${PWD}"
record_log info "==================================================================================="
record_log info ""

if [ "${PHP_EXTENSIONS}" != "" ]; then
    apk add --no-cache autoconf g++ libtool make curl-dev gettext-dev linux-headers
fi

export EXTENSIONS=",${PHP_EXTENSIONS},"

#
# Check if current php version is greater than or equal to
# specific version.
#
# For example, to check if current php is greater than or
# equal to PHP 7.0:
#
# is_php_version_greater_or_equal 7 0
#
# Param 1: Specific PHP Major version
# Param 2: Specific PHP Minor version
# Return : 1 if greater than or equal to, 0 if less than
#
function is_php_version_greater_or_equal() {
    local php_major_version=$(php -r "echo PHP_MAJOR_VERSION;")
    local php_minjor_version=$(php -r "echo PHP_MINOR_VERSION;")

    if [[ "${php_major_version}" -gt "$1" || "${php_major_version}" -eq "$1" && "${php_minjor_version}" -ge "$2" ]]; then
        return 1
    else
        return 0
    fi
}

#
# Install extension from package file(.tgz),
# For example:
#
# install_extension_from_tgz redis-5.0.2
#
# Param 1: Package name with version
# Param 2: enable options
#
function install_extension_from_tgz() {
    local package_name=$1
    local extension="${package_name%%-*}"

    mkdir ${extension}
    tar -xf ${package_name}.tgz -C ${extension} --strip-components=1
    (cd ${extension} && phpize && ./configure && make ${MC} && make install)

    docker-php-ext-enable ${extension} $2
}

# install
function install_script() {
    if [[ -z "${EXTENSIONS##*,pdo_mysql,*}" ]]; then
        record_log info "---------- Install pdo_mysql ----------"
        docker-php-ext-install ${MC} pdo_mysql
    fi

    if [[ -z "${EXTENSIONS##*,pcntl,*}" ]]; then
        record_log info "---------- Install pcntl ----------"
        docker-php-ext-install ${MC} pcntl
    fi

    if [[ -z "${EXTENSIONS##*,mysqli,*}" ]]; then
        record_log info "---------- Install mysqli ----------"
        docker-php-ext-install ${MC} mysqli
    fi

    if [[ -z "${EXTENSIONS##*,mbstring,*}" ]]; then
        record_log info "---------- mbstring is installed ----------"
    fi

    if [[ -z "${EXTENSIONS##*,exif,*}" ]]; then
        record_log info "---------- Install exif ----------"
        docker-php-ext-install ${MC} exif
    fi

    if [[ -z "${EXTENSIONS##*,bcmath,*}" ]]; then
        record_log info "---------- Install bcmath ----------"
        docker-php-ext-install ${MC} bcmath
    fi

    if [[ -z "${EXTENSIONS##*,calendar,*}" ]]; then
        record_log info "---------- Install calendar ----------"
        docker-php-ext-install ${MC} calendar
    fi

    if [[ -z "${EXTENSIONS##*,zend_test,*}" ]]; then
        record_log info "---------- Install zend_test ----------"
        docker-php-ext-install ${MC} zend_test
    fi

    if [[ -z "${EXTENSIONS##*,opcache,*}" ]]; then
        record_log info "---------- Install opcache ----------"
        docker-php-ext-install opcache
    fi

    if [[ -z "${EXTENSIONS##*,sockets,*}" ]]; then
        record_log info "---------- Install sockets ----------"
        docker-php-ext-install ${MC} sockets
    fi

    if [[ -z "${EXTENSIONS##*,gettext,*}" ]]; then
        record_log info "---------- Install gettext ----------"
        docker-php-ext-install ${MC} gettext
    fi

    if [[ -z "${EXTENSIONS##*,shmop,*}" ]]; then
        record_log info "---------- Install shmop ----------"
        docker-php-ext-install ${MC} shmop
    fi

    if [[ -z "${EXTENSIONS##*,sysvmsg,*}" ]]; then
        record_log info "---------- Install sysvmsg ----------"
        docker-php-ext-install ${MC} sysvmsg
    fi

    if [[ -z "${EXTENSIONS##*,sysvsem,*}" ]]; then
        record_log info "---------- Install sysvsem ----------"
        docker-php-ext-install ${MC} sysvsem
    fi

    if [[ -z "${EXTENSIONS##*,sysvshm,*}" ]]; then
        record_log info "---------- Install sysvshm ----------"
        docker-php-ext-install ${MC} sysvshm
    fi

    if [[ -z "${EXTENSIONS##*,pdo_firebird,*}" ]]; then
        record_log info "---------- Install pdo_firebird ----------"
        docker-php-ext-install ${MC} pdo_firebird
    fi

    if [[ -z "${EXTENSIONS##*,pdo_dblib,*}" ]]; then
        record_log info "---------- Install pdo_dblib ----------"
        docker-php-ext-install ${MC} pdo_dblib
    fi

    if [[ -z "${EXTENSIONS##*,pdo_oci,*}" ]]; then
        record_log info "---------- Install pdo_oci ----------"
        docker-php-ext-install ${MC} pdo_oci
    fi

    if [[ -z "${EXTENSIONS##*,pdo_odbc,*}" ]]; then
        record_log info "---------- Install pdo_odbc ----------"
        docker-php-ext-install ${MC} pdo_odbc
    fi

    if [[ -z "${EXTENSIONS##*,pdo_pgsql,*}" ]]; then
        record_log info "---------- Install pdo_pgsql ----------"
        apk --no-cache add postgresql-dev &&
            docker-php-ext-install ${MC} pdo_pgsql
    fi

    if [[ -z "${EXTENSIONS##*,pgsql,*}" ]]; then
        record_log info "---------- Install pgsql ----------"
        apk --no-cache add postgresql-dev &&
            docker-php-ext-install ${MC} pgsql
    fi

    if [[ -z "${EXTENSIONS##*,oci8,*}" ]]; then
        record_log info "---------- Install oci8 ----------"
        docker-php-ext-install ${MC} oci8
    fi

    if [[ -z "${EXTENSIONS##*,odbc,*}" ]]; then
        record_log info "---------- Install odbc ----------"
        docker-php-ext-install ${MC} odbc
    fi

    if [[ -z "${EXTENSIONS##*,dba,*}" ]]; then
        record_log info "---------- Install dba ----------"
        docker-php-ext-install ${MC} dba
    fi

    if [[ -z "${EXTENSIONS##*,interbase,*}" ]]; then
        record_log warn "---------- Install interbase ----------"
        record_log error "Alpine linux do not support interbase/firebird!!!"
        #docker-php-ext-install ${MC} interbase
    fi

    if [[ -z "${EXTENSIONS##*,gd,*}" ]]; then
        record_log info "---------- Install gd ----------"

        is_php_version_greater_or_equal 7 4

        if [[ "$?" == "1" ]]; then
            record_log warn "---------- gd PHP >= 7.4 ----------"
            apk add --no-cache freetype-dev libjpeg-turbo-dev libpng-dev &&
                docker-php-ext-configure gd &&
                docker-php-ext-install ${MC} gd
        else
            record_log warn "---------- gd PHP < 7.4 ----------"
            apk add --no-cache freetype-dev libjpeg-turbo-dev libpng-dev &&
                docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ &&
                docker-php-ext-install ${MC} gd
        fi
    fi

    if [[ -z "${EXTENSIONS##*,intl,*}" ]]; then
        record_log info "---------- Install intl ----------"
        apk add --no-cache icu-dev
        docker-php-ext-install ${MC} intl
    fi

    if [[ -z "${EXTENSIONS##*,bz2,*}" ]]; then
        record_log info "---------- Install bz2 ----------"
        apk add --no-cache bzip2-dev
        docker-php-ext-install ${MC} bz2
    fi

    if [[ -z "${EXTENSIONS##*,soap,*}" ]]; then
        record_log info "---------- Install soap ----------"
        apk add --no-cache libxml2-dev
        docker-php-ext-install ${MC} soap
    fi

    if [[ -z "${EXTENSIONS##*,xsl,*}" ]]; then
        record_log info "---------- Install xsl ----------"
        apk add --no-cache libxml2-dev libxslt-dev
        docker-php-ext-install ${MC} xsl
    fi

    if [[ -z "${EXTENSIONS##*,xmlrpc,*}" ]]; then
        record_log info "---------- Install xmlrpc ----------"
        apk add --no-cache libxml2-dev libxslt-dev
        docker-php-ext-install ${MC} xmlrpc
    fi

    if [[ -z "${EXTENSIONS##*,wddx,*}" ]]; then
        record_log info "---------- Install wddx ----------"
        apk add --no-cache libxml2-dev libxslt-dev
        docker-php-ext-install ${MC} wddx
    fi

    if [[ -z "${EXTENSIONS##*,curl,*}" ]]; then
        record_log info "---------- curl is installed ----------"
    fi

    if [[ -z "${EXTENSIONS##*,readline,*}" ]]; then
        record_log info "---------- Install readline ----------"
        apk add --no-cache readline-dev
        apk add --no-cache libedit-dev
        docker-php-ext-install ${MC} readline
    fi

    if [[ -z "${EXTENSIONS##*,snmp,*}" ]]; then
        record_log info "---------- Install snmp ----------"
        apk add --no-cache net-snmp-dev
        docker-php-ext-install ${MC} snmp
    fi

    if [[ -z "${EXTENSIONS##*,pspell,*}" ]]; then
        record_log info "---------- Install pspell ----------"
        apk add --no-cache aspell-dev
        apk add --no-cache aspell-en
        docker-php-ext-install ${MC} pspell
    fi

    if [[ -z "${EXTENSIONS##*,recode,*}" ]]; then
        record_log info "---------- Install recode ----------"
        apk add --no-cache recode-dev
        docker-php-ext-install ${MC} recode
    fi

    if [[ -z "${EXTENSIONS##*,tidy,*}" ]]; then
        record_log info "---------- Install tidy ----------"
        apk add --no-cache tidyhtml-dev

        # Fix: https://github.com/htacg/tidy-html5/issues/235
        ln -s /usr/include/tidybuffio.h /usr/include/buffio.h

        docker-php-ext-install ${MC} tidy
    fi

    if [[ -z "${EXTENSIONS##*,gmp,*}" ]]; then
        record_log info "---------- Install gmp ----------"
        apk add --no-cache gmp-dev
        docker-php-ext-install ${MC} gmp
    fi

    if [[ -z "${EXTENSIONS##*,imap,*}" ]]; then
        record_log info "---------- Install imap ----------"
        apk add --no-cache imap-dev
        docker-php-ext-configure imap --with-imap --with-imap-ssl
        docker-php-ext-install ${MC} imap
    fi

    if [[ -z "${EXTENSIONS##*,ldap,*}" ]]; then
        record_log info "---------- Install ldap ----------"
        apk add --no-cache ldb-dev
        apk add --no-cache openldap-dev
        docker-php-ext-install ${MC} ldap
    fi

    if [[ -z "${EXTENSIONS##*,imagick,*}" ]]; then
        record_log info "---------- Install imagick ----------"
        apk add --no-cache file-dev
        apk add --no-cache imagemagick-dev
        printf "\n" | pecl install imagick-3.4.4
        docker-php-ext-enable imagick
    fi

    if [[ -z "${EXTENSIONS##*,rar,*}" ]]; then
        record_log info "---------- Install rar ----------"
        printf "\n" | pecl install rar
        docker-php-ext-enable rar
    fi

    if [[ -z "${EXTENSIONS##*,ast,*}" ]]; then
        record_log info "---------- Install ast ----------"
        printf "\n" | pecl install ast
        docker-php-ext-enable ast
    fi

    if [[ -z "${EXTENSIONS##*,msgpack,*}" ]]; then
        record_log info "---------- Install msgpack ----------"
        printf "\n" | pecl install msgpack
        docker-php-ext-enable msgpack
    fi

    if [[ -z "${EXTENSIONS##*,igbinary,*}" ]]; then
        record_log info "---------- Install igbinary ----------"
        printf "\n" | pecl install igbinary
        docker-php-ext-enable igbinary
    fi

    if [[ -z "${EXTENSIONS##*,yac,*}" ]]; then
        record_log info "---------- Install yac ----------"
        printf "\n" | pecl install yac-2.0.2
        docker-php-ext-enable yac
    fi

    if [[ -z "${EXTENSIONS##*,yaconf,*}" ]]; then
        record_log info "---------- Install yaconf ----------"
        printf "\n" | pecl install yaconf
        docker-php-ext-enable yaconf
    fi

    if [[ -z "${EXTENSIONS##*,seaslog,*}" ]]; then
        record_log info "---------- Install seaslog ----------"
        printf "\n" | pecl install seaslog
        docker-php-ext-enable seaslog
    fi

    if [[ -z "${EXTENSIONS##*,varnish,*}" ]]; then
        record_log info "---------- Install varnish ----------"
        apk add --no-cache varnish-dev
        printf "\n" | pecl install varnish
        docker-php-ext-enable varnish
    fi

    if [[ -z "${EXTENSIONS##*,pdo_sqlsrv,*}" ]]; then
        is_php_version_greater_or_equal 7 1
        if [[ "$?" == "1" ]]; then
            record_log info "---------- Install pdo_sqlsrv ----------"
            apk add --no-cache unixodbc-dev
            printf "\n" | pecl install pdo_sqlsrv
            docker-php-ext-enable pdo_sqlsrv
        else
            record_log debug "pdo_sqlsrv requires PHP >= 7.1.0, installed version is ${PHP_VERSION}"
        fi
    fi

    if [[ -z "${EXTENSIONS##*,sqlsrv,*}" ]]; then
        is_php_version_greater_or_equal 7 1
        if [[ "$?" == "1" ]]; then
            record_log info "---------- Install sqlsrv ----------"
            apk add --no-cache unixodbc-dev
            printf "\n" | pecl install sqlsrv
            docker-php-ext-enable sqlsrv
        else
            record_log debug "pdo_sqlsrv requires PHP >= 7.1.0, installed version is ${PHP_VERSION}"
        fi
    fi

    if [[ -z "${EXTENSIONS##*,mcrypt,*}" ]]; then
        is_php_version_greater_or_equal 7 2
        if [[ "$?" == "1" ]]; then
            record_log info "---------- mcrypt was REMOVED from PHP 7.2.0 ----------"
        else
            record_log warn "---------- Install mcrypt ----------"
            apk add --no-cache libmcrypt-dev &&
                docker-php-ext-install ${MC} mcrypt
        fi
    fi

    if [[ -z "${EXTENSIONS##*,mysql,*}" ]]; then
        is_php_version_greater_or_equal 7 0

        if [[ "$?" == "1" ]]; then
            record_log info "---------- mysql was REMOVED from PHP 7.0.0 ----------"
        else
            record_log info "---------- Install mysql ----------"
            docker-php-ext-install ${MC} mysql
        fi
    fi

    if [[ -z "${EXTENSIONS##*,sodium,*}" ]]; then
        is_php_version_greater_or_equal 7 2
        if [[ "$?" == "1" ]]; then
            record_log info ""
            record_log info "Sodium is bundled with PHP from PHP 7.2.0"
            record_log info ""
        else
            record_log warn "---------- Install sodium ----------"
            apk add --no-cache libsodium-dev
            docker-php-ext-install ${MC} sodium
        fi
    fi

    if [[ -z "${EXTENSIONS##*,amqp,*}" ]]; then
        record_log info "---------- Install amqp ----------"
        apk add --no-cache rabbitmq-c-dev
        install_extension_from_tgz amqp-1.9.4
    fi

    if [[ -z "${EXTENSIONS##*,redis,*}" ]]; then
        record_log info "---------- Install redis ----------"
        is_php_version_greater_or_equal 7 0
        if [[ "$?" == "1" ]]; then
            install_extension_from_tgz redis-5.1.1
        else
            printf "\n" | pecl install redis-4.3.0
            docker-php-ext-enable redis
        fi
    fi

    if [[ -z "${EXTENSIONS##*,apcu,*}" ]]; then
        record_log info "---------- Install apcu ----------"
        install_extension_from_tgz apcu-5.1.17
    fi

    if [[ -z "${EXTENSIONS##*,memcached,*}" ]]; then
        record_log info "---------- Install memcached ----------"
        apk add --no-cache libmemcached-dev zlib-dev
        is_php_version_greater_or_equal 7 0

        if [[ "$?" == "1" ]]; then
            printf "\n" | pecl install memcached-3.1.3
        else
            printf "\n" | pecl install memcached-2.2.0
        fi

        docker-php-ext-enable memcached
    fi

    if [[ -z "${EXTENSIONS##*,xdebug,*}" ]]; then
        record_log info "---------- Install xdebug ----------"
        is_php_version_greater_or_equal 7 0

        if [[ "$?" == "1" ]]; then
            install_extension_from_tgz xdebug-2.9.0
        else
            install_extension_from_tgz xdebug-2.5.5
        fi
    fi

    if [[ -z "${EXTENSIONS##*,event,*}" ]]; then
        record_log info "---------- Install event ----------"
        apk add --no-cache libevent-dev
        export is_sockets_installed=$(php -r "echo extension_loaded('sockets');")

        if [[ "${is_sockets_installed}" == "" ]]; then
            record_log info "---------- event is depend on sockets, install sockets first ----------"
            docker-php-ext-install sockets
        fi

        record_log info "---------- Install event again ----------"
        install_extension_from_tgz event-2.5.3 "--ini-name event.ini"
    fi

    if [[ -z "${EXTENSIONS##*,mongodb,*}" ]]; then
        record_log info "---------- Install mongodb ----------"
        install_extension_from_tgz mongodb-1.5.5
    fi

    if [[ -z "${EXTENSIONS##*,yaf,*}" ]]; then
        record_log info "---------- Install yaf ----------"
        is_php_version_greater_or_equal 7 0

        if [[ "$?" == "1" ]]; then
            printf "\n" | pecl install yaf
            docker-php-ext-enable yaf
        else
            install_extension_from_tgz yaf-2.3.5
        fi
    fi

    if [[ -z "${EXTENSIONS##*,swoole,*}" ]]; then
        record_log info "---------- Install swoole ----------"
        is_php_version_greater_or_equal 7 0

        if [[ "$?" == "1" ]]; then
            install_extension_from_tgz swoole-4.4.13
        fi
    fi

    if [[ -z "${EXTENSIONS##*,zip,*}" ]]; then
        record_log info "---------- Install zip ----------"
        # Fix: https://github.com/docker-library/php/issues/797
        apk add --no-cache libzip-dev
        docker-php-ext-configure zip --with-libzip=/usr/include

        docker-php-ext-install ${MC} zip
    fi

    if [[ -z "${EXTENSIONS##*,xhprof,*}" ]]; then
        record_log info "---------- Install XHProf ----------"
        is_php_version_greater_or_equal 7 0

        if [[ "$?" == "1" ]]; then
            mkdir xhprof &&
                tar -xf xhprof-2.1.0.tgz -C xhprof --strip-components=1 &&
                (cd xhprof/extension/ && phpize && ./configure && make ${MC} && make install) &&
                docker-php-ext-enable xhprof
        else
            record_log warn "---------- PHP Version>= 7.0----------"
        fi
    fi

    if [[ -z "${EXTENSIONS##*,xlswriter,*}" ]]; then
        record_log info "---------- Install xlswriter ----------"
        is_php_version_greater_or_equal 7 0

        if [[ "$?" == "1" ]]; then
            printf "\n" | pecl install xlswriter
            docker-php-ext-enable xlswriter
        else
            record_log warn "---------- PHP Version>= 7.0----------"
        fi
    fi
}

function main() {
    is_php_version_greater_or_equal
    install_extension_from_tgz
    install_script
    exit 0
}

main
