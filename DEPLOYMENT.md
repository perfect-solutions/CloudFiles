# Ways to Deployment

- Docker image
- "Puppet apply" deployemnt
- "Ansible" deployment
- bash deployment

## Introduction to deploy

CloudFiles can runs on role-splitted servers or on all-in-one server variants (for dev/test environments). CloudFiles deployment has a three roles:

- Front (Nginx front-end for "PHP Upload Service", load-balance and pass connections next)
- PHP Upload Service (This is sharding, replication, standby and other logic. Uses the "Storage Node"s)
- Storage Node (Nginx for uploading files and downloading files)

You can deploy it on 1-2-3-6-15-25-N servers for each role, for your project requrements. You can add new servers to production cluster without downtime. You can deploy all roles to one server.

## Docker image

To pull image use next command:

     docker pull perfectsolutions/cloudfiles:stable

To run role "Front" use next command:

     docker run perfectsolutions/cloudfiles:stable /pscf-ep.sh --front

To run role "PHP Upload Service" next next:

     docker run perfectsolutions/cloudfiles:stable /pscf-ep.sh --php-upload-service

To run role "Storage" user next command:

     docker run perfectsolutions/cloudfiles:stable -v /path/to/your/storage:/var/pscf/sh-data /pscf-ep.sh --storage

## Puppet apply way

This is have a three steps of deployment:

- configure
- deployment
- check

For configure please run ```./deployemnt/configure --interactive``` and ask to questions.

For deployment please run ```./deployment/run --method=puppet``` and wait for deployment has been finished.

For check please run ```./deployment/check``` and get results of self-checking. 

For clear configuration please run ```./deployment/configre --clean```. After it your can re-run configure step.

## Ansible apply way

This is have a three steps too:

- configure
- deployment
- check

For configure please run ```./deployemnt/configure --interactive``` and ask to questions.

For deployment please run ```./deployment/run --method=ansible``` and wait for deployment has been finished.

For check please run ```./deployment/check``` and get results of self-checking. 

For clear configuration please run ```./deployment/configre --clean```. After it your can re-run configure step.

## BASH deplyment way

This is not recommended way, but if your OS not have a ansible/puppet/docker, You can deploy with bash-script. 

For deploy role to server please run:

    ./deployment/raw-bash (front|php-upload-service|storage)

Your can run it for each all roles on one server.

## Deployment side effects:

- If nginx already installed, it will be **restarted**
- If php-fpm already installed, it will be **restarted**
- Deployment scripts installs next software: nginx, php-fpm

