#!/usr/bin/env bash

export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"

set -e

sc=`realpath $0`
d=`dirname $sc`

if [ "`cat /etc/debian_version | tr "." " " | awk '{print $1}'`" == "9" ]; then
    ansible-playbook -i $d/inventory $d/debian9-ansible.yml
elif [ "`cat /etc/debian_version | tr "." " " | awk '{print $1}'`" == "8" ]; then
    ansible-playbook -i $d/inventory $d/debian8-ansible.yml
else
    echo "Unsupported debian version"
fi


