#!/bin/bash

username=$1

if [ "$username" == "" ]; then
    echo ""
    echo "./public.sh username"
    echo ""
    exit 1
fi

export DOCKER_ID_USER="$username"
docker login

docker tag cloudfiles:latest perfectsolutions/cloudfiles:latest
docker push perfectsolutions/cloudfiles:latest
