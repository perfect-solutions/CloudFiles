#!/usr/bin/env bash

export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"

NOSTART=$1

if [ "$NOSTART" != "--no-start" ]; then
	NOSTART="--start"
fi

set -e

sc=`realpath $0`
d=`dirname $sc`

puppet apply --verbose $d/puppet.pp

gt16=`lsb_release -r | awk '{print $2 "-16>0"}' | bc`

if [ "$gt16" == "1" ]; then
    php=php7.0-fpm
else
    php=php5-fpm
fi

if [ "$NOSTART" == "--start" ]; then

	#FPM
	systemctl stop $php || true
	systemctl start $php

	#NGINX
	systemctl stop nginx || true
	systemctl start nginx

	#enable after
	systemctl enable nginx
	systemctl enable $php
fi;

#copyfiles
dd=`dirname $d`
ddd=`dirname $dd`
echo $ddd
cp -vax $ddd/* /var/pscf/cloud-files/
rm -rf /var/pscf/cloud-files/deployment/
chown -R pscf:pscf /var/pscf/cloud-files/
