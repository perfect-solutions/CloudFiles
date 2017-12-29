FROM debian:stretch

MAINTAINER Perfect Solutions version: 1.0

RUN apt-get update &&\
 apt-get install -y git puppet &&\
 git clone https://github.com/perfect-solutions/CloudFiles.git /root/CloudFiles &&\
 cd /root/CloudFiles &&\
 git checkout dev-deployment &&\
 ls -la /root/CloudFiles/ &&\
 ls -la /root/CloudFiles/deployment &&\
 ls -la /root/CloudFiles/deployment/internal &&\
 /root/CloudFiles/deployment/internal/puppet-debian-install.sh --no-start &&\
 apt-get purge -y git puppet &&\
 rm -rf /var/lib/puppet &&\
 apt-get clean &&\
 rm -rf /etc/php/7.0/fpm/pool.d/www.conf &&\
 rm -rf /etc/nginx/sites-enabled/default &&\
 rm -rf /root/CloudFiles

EXPOSE 80
EXPOSE 9001
