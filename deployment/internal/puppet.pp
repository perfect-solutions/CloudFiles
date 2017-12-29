
class ps_cf_nginx_dir {

    file { "/etc/nginx/ps-infra-deployment":
	ensure => "directory",
	owner => "root",
	group => "root",
	mode => "0750",
	require => Exec["touch /tmp/ps-cf-deployment-update"],
    }

}

class ps_cf_required_software_php {
    
    case $::osfamily {
       'redhat': {
         $packages = [ "php-fpm", "php-cli", "policycoreutils-python" ]
       }
       'debian': {
         $packages = [ "php5-fpm", "php5-cli" ]
       }
       default: {
         # ...
       }
    }

    package { $packages:
	ensure => "installed",
	allow_virtual => true
    }

}

class ps_cf_required_software_storage {


    include ps_cf_required_software_storage

}

class ps_cf_required_software_front {

    case $::osfamily {
       'redhat': {
	 $flag = "nginx-all-modules"
         $packages = [ "nginx-all-modules" ]
       }
       'debian': {
	 $flag = "nginx-extras"
         $packages = [ "nginx-extras" ]
       }
       default: {
         # ...
       }
    }


    package { $packages:
	ensure => "installed",
	allow_virtual => true,
    }

    exec { "touch /tmp/ps-cf-deployment-update":
	path => "/usr/bin:/bin",
	require => Package[$flag]
    }

}


define ps_cf_configure_sh_rpl_x($shard, $rpl, $temp_path, $path, $server_name, $private_ip, $public_ip, $public_server_name, $logdir, $access_download) {

    include ps_cf_required_software_storage
    include ps_cf_nginx_dir

    file { "/etc/nginx/ps-infra-deployment/ps-cloudstorage-storage-sh$shard-rpl$rpl-upl.conf":
	ensure => "present",
	owner => "root",
	group => "root",
	mode => "0640",
	require => Class[ps_cf_nginx_dir],
	content => template("/root/CloudFiles/deployment/internal/templates/etc/nginx/ps-infra-deployment/ps-cloudfiles-storage-sh-rpl-upl.conf"),
    }

    file { "/etc/nginx/ps-infra-deployment/ps-cloudstorage-storage-sh$shard-rpl$rpl-download.conf":
	ensure => "present",
	owner => "root",
	group => "root",
	mode => "0640",
	require => Class[ps_cf_nginx_dir],
	content => template("/root/CloudFiles/deployment/internal/templates/etc/nginx/ps-infra-deployment/ps-cloudfiles-storage-sh-rpl-download.conf"),
    }

    file { "$path":
	ensure => "directory",
	owner => "pscf",
	group => "pscf",
	mode => "0750",
	require => Class[ps_cf_nginx_dir],
    }

    file { "$temp_path":
	ensure => "directory",
	owner => "pscf",
	group => "pscf",
	mode => "0750",
	require => Class[ps_cf_nginx_dir],
    }

    file { "$logdir":
	ensure => "directory",
	owner => "pscf",
	group => "pscf",
	mode => "0775",
	require => Class[ps_cf_nginx_dir],
    }

}

define ps_cf_configure_php_node($max_concurrent_uploads, $cf_user, $cf_group, $cf_php_host, $cf_php_port, $logdir)
{
    include ps_cf_required_software_php

    case $::osfamily {
       'redhat': {
         $fpm_pool_path = "/etc/php-fpm.d"
       }
       'debian': {
         $fpm_pool_path = "/etc/php5-fpm/pool.d"
       }
       default: {
         # ...
       }
    }

    file { "$fpm_pool_path/ps_cf_php.conf":
	ensure => "present",
	owner => "root",
	group => "root",
	mode => "0640",
	require => Class[ps_cf_required_software_php],
	content => template("/root/CloudFiles/deployment/internal/templates/etc/php-fpm-pool.d/ps_cf_php.conf")
    }

    file { "$logdir":
	ensure => "directory",
	owner => "$cf_user",
	group => "$cf_group",
	mode => "0775",
	require => Class[ps_cf_required_software_php],
    }

}

define ps_cf_configure_front($cf_php_host_port_list, $cf_private_ip, $cf_private_server_name, $directory_to_deploy, $cf_user, $cf_group)
{
    include ps_cf_required_software_front
    include ps_cf_nginx_dir

    file { "/etc/nginx/ps-infra-deployment/ps-cloudstorage-front.conf":
	ensure => "present",
	owner => "root",
	group => "root",
	mode => "0640",
	require => Class[ps_cf_nginx_dir],
	content => template("/root/CloudFiles/deployment/internal/templates/etc/nginx/ps-infra-deployment/ps-cloudfiles-front.conf"),
    }

    file { "$directory_to_deploy":
	ensure => "directory",
	owner => "$cf_user",
	group => "$cf_group",
	mode => "0750",
	require => Class[ps_cf_nginx_dir],
    }

}

node "localhost" {

 file {  "/var/pscf":
    ensure => directory,
    owner => "pscf",
    group => "pscf",
    mode => "700",
    require => User["pscf"]
 }

 group { "pscf":
    ensure => "present",
    system => true,
 }
 
 user { "pscf":
    ensure => "present",
    system => true,
    groups => "pscf",
    shell => "/bin/false",
    require => Group["pscf"]
 }

 ps_cf_configure_sh_rpl_x { "a":
    shard => "0",
    rpl => "0",
    temp_path => "/var/pscf/sh-tmp",
    path => "/var/pscf/sh-data",
    server_name => "sh0rpl0.local",
    private_ip => "127.0.0.1",
    public_ip => "0.0.0.0",
    public_server_name => "sh0rpl0",
    logdir => "/var/log/nginx",
    access_download => "no",
    require => File["/var/pscf"]
 }

 ps_cf_configure_front { "b":
    cf_php_host_port_list => [ { "host" => "127.0.0.1", "port"=>"9001" } ] ,
    cf_private_ip => "127.0.0.1",
    cf_private_server_name => "upload.local",
    directory_to_deploy => "/var/pscf/cloud-files/",
    cf_user => "pscf",
    cf_group => "pscf",
    require => File["/var/pscf"]
 }
 
 ps_cf_configure_php_node { "c":
    max_concurrent_uploads => "10",
    cf_user => "pscf",
    cf_group => "pscf",
    cf_php_host => "127.0.0.1",
    cf_php_port => "9001",
    logdir => "/var/log/php5-fpm/",
    require => File["/var/pscf"]
 }

}
