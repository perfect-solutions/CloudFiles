#!/usr/bin/env bash

export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"

sc=`realpath $0`
d=`dirname $sc`

puppet apply --verbose $d/puppet.pp

#FPM
systemctl stop php-fpm
systemctl start php-fpm
$d/rhel-allow-audit.sh
systemctl stop php-fpm
systemctl start php-fpm


#NGINX
systemctl stop nginx
systemctl start nginx

#enable after
systemctl enable nginx
systemctl enable php-fpm

#copyfiles
dd=`dirname $d`
ddd=`dirname $dd`
echo $ddd
cp -vax $ddd/* /var/pscf/cloud-files/
rm -rf /var/pscf/cloud-files/deployment/
chown -R pscf:pscf /var/pscf/cloud-files/
