FROM php:7.2-fpm
MAINTAINER Kane Valentine <kane@cute.im>

RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libldap2-dev \
	; \
	\
	docker-php-ext-configure ldap --with-libdir=/lib/x86_64-linux-gnu; \
	docker-php-ext-install ldap; \
	\
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

VOLUME /var/www/html

ENV LTB_PHP_SLFSRV_VERSION 1.2
ENV LTB_PHP_SLFSRV_SHA1 67ef68b1b977c5cfbd47b7b6341841fb53cb5e60

RUN set -ex; \
	curl -o php-ldap-slfsrv.tar.gz -fSL "http://ltb-project.org/archives/ltb-project-self-service-password-${LTB_PHP_SLFSRV_VERSION}.tar.gz"; \
        echo "$LTB_PHP_SLFSRV_SHA1 *php-ldap-slfsrv.tar.gz" | sha1sum -c -; \
	tar -xzf php-ldap-slfsrv.tar.gz -C /usr/src/; \
	rm php-ldap-slfsrv.tar.gz; \
	chown -R www-data:www-data /usr/src/ltb-project-self-service-password-${LTB_PHP_SLFSRV_VERSION}

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
