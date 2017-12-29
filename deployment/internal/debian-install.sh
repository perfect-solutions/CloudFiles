#!/usr/bin/env bash

export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"

set -x

sc=`realpath $0`
d=`dirname $sc`

puppet apply --verbose $d/puppet.pp

if [ "`cat /etc/debian_version | tr "." " " | awk '{print $1}'`" == "9" ]; then
    php=php7.0-fpm
else
    php=php5-fpm
fi

#FPM
systemctl stop $php
systemctl start $php

#NGINX
systemctl stop nginx
systemctl start nginx

#enable after
systemctl enable nginx
systemctl enable $php

#copyfiles
dd=`dirname $d`
ddd=`dirname $dd`
echo $ddd
cp -vax $ddd/* /var/pscf/cloud-files/
rm -rf /var/pscf/cloud-files/deployment/
chown -R pscf:pscf /var/pscf/cloud-files/
