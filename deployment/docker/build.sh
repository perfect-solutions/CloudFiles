#!/bin/bash

d=`realpath $0`
cd $d
#docker build --tag cloudfiles:latest --no-cache ./
docker build --tag cloudfiles:latest ./
