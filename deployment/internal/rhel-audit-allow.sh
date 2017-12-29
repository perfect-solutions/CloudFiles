#!/usr/bin/env bash

export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"

fgrep php-fpm /var/log/audit/audit.log | audit2allow -M phpfpmlocal
semodule -i phpfpmlocal.pp


