
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
         $packages = []
       }
       'debian': {
         $packages = [ "php5-fpm", "php5-cli" ]
       }
       default: {
         # ...
       }
    }

    package { $packages:
	ensure => "installed"
    }

}

class ps_cf_required_software_storage {
    
    case $::osfamily {
       'redhat': {
	 $flag = "nginx"
         $packages = [ "nginx" ]
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
	ensure => "installed"
    }

    Exec { "touch /tmp/ps-cf-deployment-update":
	path => "/usr/bin:/bin",
	require => Package[$flag]
    }

}

class ps_cf_required_software_front {

    case $::osfamily {
       'redhat': {
	 $flag = "nginx"
         $packages = [ "nginx" ]
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
	ensure => "installed"
    }

    Exec { "touch /tmp/ps-cf-deployment-update":
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
	content => "internal/templates/etc/nginx/ps-infra-deployment/ps-cloudfiles-storage-sh-rpl-upl.conf",
    }

    file { "/etc/nginx/ps-infra-deployment/ps-cloudstorage-storage-sh$shard-rpl$rpl-download.conf":
	ensure => "present",
	owner => "root",
	group => "root",
	mode => "0640",
	require => Class[ps_cf_nginx_dir],
	content => "internal/templates/etc/nginx/ps-infra-deployment/ps-cloudfiles-storage-sh-rpl-download.conf",
    }

    file { "$path":
	ensure => "directory",
	owner => "www-data",
	group => "www-data",
	mode => "0750",
	require => Class[ps_cf_nginx_dir],
    }

    file { "$temp_path":
	ensure => "directory",
	owner => "www-data",
	group => "www-data",
	mode => "0750",
	require => Class[ps_cf_nginx_dir],
    }

    file { "$logdir":
	ensure => "directory",
	owner => "www-data",
	group => "www-data",
	mode => "0775",
	require => Class[ps_cf_nginx_dir],
    }

}

define ps_cf_configure_php_node($max_concurrent_uploads, $cf_user, $cf_group, $cf_php_host, $cf_php_port, $logdir)
{
    include ps_cf_required_software_php

    $fpm_poll_path = "/etc/php5-fpm/pool.d"

    file { "$fpm_pool_path/ps_cf_php.conf":
	ensure => "present",
	owner => "root",
	group => "root",
	mode => "0640",
	require => Class[ps_cf_required_software_php],
	content => "internal/templates/etc/php-fpm-pool.d/ps_cf_php.conf"
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
	content => "internal/templates/etc/nginx/ps-infra-deployment/ps-cloudfiles-front.conf",
    }

    file { "$directory_to_deploy":
	ensure => "directory",
	owner => "$cf_user",
	group => "$cf_group",
	mode => "0750",
	require => Class[ps_cf_nginx_dir],
    }

}

