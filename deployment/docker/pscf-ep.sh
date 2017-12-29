#!/bin/bash

PATH=/usr/sbin:/usr/bin:/sbin:/bin

role=$1

case "$role" in
    --front)
	/bin/cp /etc/nginx/ps-infra-deployment/ps-cloudstorage-front.conf /etc/nginx/sites-enabled/
	/usr/sbin/nginx -t
	/usr/sbin/nginx -c /etc/nginx/nginx.conf
	;;
    --php-upload-service)
	/usr/sbin/php-fpm7.0 -F -c /etc/php/7.0/fpm/php.ini -y /etc/php/7.0/fpm/php-fpm.conf -O -t
	/usr/sbin/php-fpm7.0 -F -c /etc/php/7.0/fpm/php.ini -y /etc/php/7.0/fpm/php-fpm.conf -O
	;;
    --storage)
	/bin/cp /etc/nginx/ps-infra-deployment/ps-cloudstorage-storage-sh*.conf /etc/nginx/sites-enabled/
	/usr/sbin/nginx -t
	/usr/sbin/nginx -c /etc/nginx/nginx.conf
	;;
    *)
	echo "You must select role for run: docker run perfectsolutions/cloudfiles:used-tag /pscf-ep.sh (--front|--php-upload-service|--storage)"
	exit 2
	;;
esac