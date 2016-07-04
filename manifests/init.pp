# == Class: elastic
# ===========================
#
#
# Description of the Class:
#
#   Install and configure the elasticsearch service
#      which is providing access to real time data
#
#
# Document all Parameters:
#
#   clustername       = the elasticsearch cluster name
#   cluster_servers   = the servers addresses to configure the cluster
#   version           = version to install
#   repo_version      = yum repo version
#   repo_manage       = 'true' for installing the yum.repo file
#   auto_upgrade      = 'false' for NOT to autoupgrade ES
#   java_manage       = 'true' for installing Java
#   java_pkg          = which java package to install
#   elastic_ca_cert   = the CA certificate for the ELK stack
#   elastic_cert      = the certificate for the elastic cluster
#   elastic_key       = the private for the elastic cluster
#   keystore_dir      = leave as default
#   keystore_passwd   = java keystore password
#   data_dir          = directory for saving the ES data
#
#
# ===========================
#
#
# == Authors
# ----------
#
# Author: Addi <addi.abel@gmail.com>
#
#
# == Copyright
# ------------
#
# Copyright:  ©  2016  LR / Addi.
#
#
class elastic (
  $clustername                 = hiera('elk_stack_elastic_clustername'),
  $instance                    = hiera('elk_stack_elastic_instance'),
  $cluster_servers             = hiera('elk_stack_elastic_servers'),
  $version                     = '2.3.2',
  $repo_version                = '2.x',
  $repo_manage                 = true,
  $auto_upgrade                = false,
  $java_manage                 = true,
  $java_pkg                    = 'java-1.8.0-openjdk',
  $keystore_dir                = undef,
  $keystore_passwd             = "keystore_pass",
  $elastic_ca_cert             = '/etc/pki/ca-trust/source/anchors/elk_ca_cert.crt',
  $elastic_cert                = '/etc/elasticsearch/ssl/elastic.crt',
  $elastic_key                 = '/etc/elasticsearch/ssl/elastic.key',
  $data_dir                    = '/var/lib/elasticsearch',
){

  notify { "## --->>> Installing and configuring ${clustername}": }

  class { 'elasticsearch':
    version                    => $version,
    manage_repo                => $repo_manage,
    repo_version               => $repo_version,
    autoupgrade                => $auto_upgrade,
    java_install               => $java_manage,
    java_package               => $java_pkg,
    datadir                    => $data_dir,
    config                     => {
      'cluster.name'           =>  $clustername,
      'discovery.zen.ping.multicast.enabled' => false,
      'discovery.zen.ping.unicast.hosts'     => $cluster_servers,
      'network.host'           =>  $::ipaddress_eth1
      }
    }

  elasticsearch::instance { "ops-els":
    ssl                        => true,
    ca_certificate             => $elastic_ca_cert,
    certificate                => $elastic_cert,
    private_key                => $elastic_key,
    keystore_path              => $keystore_dir,
    keystore_password          => $keystore_passwd,
    }

  elasticsearch::plugin{ 'mobz/elasticsearch-head':
    instances                  => $instance,
    }
  
  elasticsearch::plugin{ 'lmenezes/elasticsearch-kopf':
    instances                  => $instance,
    }
  
  file { "/etc/elasticsearch/ssl" :
    ensure                     => 'directory',
    owner                      => 'root',
    group                      => 'root',
    mode                       => '0755',
    }

  file { $elastic_key:
    ensure                     => file,
    owner                      => 'root',
    group                      => 'root',
    mode                       => '0644',
    content                    => hiera('elk_stack_elastic_key')
    }

  file { $elastic_cert:
    ensure                     => file,
    owner                      => 'root',
    group                      => 'root',
    mode                       => '0644',
    content                    => hiera('elk_stack_elastic_cert')
    }

  }

# vim: set ts=2 sw=2 et :
