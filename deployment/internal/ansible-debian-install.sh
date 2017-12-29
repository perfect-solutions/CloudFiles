#!/usr/bin/env bash

export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"

set -e

sc=`realpath $0`
d=`dirname $sc`

ansible-playbook -i $d/inventory $d/debian9-ansible.yml

