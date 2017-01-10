# == Class: elastic::install
# ===========================
#
#
# Description of the Class:
#
#   This class is meant to be called from init.pp only.
#
#
# ===========================
#
class elastic::install (
  $version                     = $elastic::params::version,
  $repo_version                = $elastic::params::repo_version,
  $repo_manage                 = $elastic::params::repo_manage,
  $auto_upgrade                = $elastic::params::auto_upgrade,
  $java_manage                 = $elastic::params::java_manage,
  $java_pkg                    = $elastic::params::java_pkg,
  $clustername                 = $elastic::params::clustername,
  $instance                    = $elastic::params::instance,
  $cluster_servers             = $elastic::params::cluster_servers,
  $keystore_dir                = $elastic::params::keystore_dir,
  $keystore_passwd             = $elastic::params::keystore_passwd,
  $ssl_cacert_file             = $elastic::params::ssl_cacert_file,
  $elastic_cert                = $elastic::params::elastic_cert,
  $elastic_key                 = $elastic::params::elastic_key,
  $data_dir                    = $elastic::params::data_dir
) {

  include elastic::params

  notify { "## --->>> Installing and configuring ${clustername}": }

  class { 'elasticsearch':
    version      => $version,
    manage_repo  => $repo_manage,
    repo_version => $repo_version,
    autoupgrade  => $auto_upgrade,
    java_install => $java_manage,
    java_package => $java_pkg,
    datadir      => $data_dir,
    config       => {
      'cluster.name'                         => $clustername,
      'discovery.zen.ping.multicast.enabled' => false,
      'discovery.zen.ping.unicast.hosts'     => $cluster_servers,
      'network.host'                         => $::ipaddress_eth1
      }
    }

  elasticsearch::instance { $instance:
    ssl               => true,
    ca_certificate    => $ssl_cacert_file,
    certificate       => $elastic_cert,
    private_key       => $elastic_key,
    keystore_path     => $keystore_dir,
    keystore_password => $keystore_passwd,
    }

  elasticsearch::plugin{ 'mobz/elasticsearch-head':
    instances => $instance,
    }

  elasticsearch::plugin{ 'lmenezes/elasticsearch-kopf':
    instances => $instance,
    }

  file { '/etc/elasticsearch/ssl' :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    }

  file { $elastic_key:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => hiera('elk_stack_elastic_key')
    }

  file { $elastic_cert:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => hiera('elk_stack_elastic_cert')
    }

  }

# vim: set ts=2 sw=2 et :
