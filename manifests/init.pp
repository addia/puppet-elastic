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
#   Explanation of what this parameter affects and what it defaults to.
#   clustername       = the elasticsearch cluster name
#   version           = version to install
#   repo_version      = yum repo version
#   repo_manage       = 'true' for installing the yum.repo file
#   auto_upgrade      = 'false' for NOT to autoupgrade ES
#   java_manage       = 'true' for installing Java
#   java_pkg          = which java package to install
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
  $clustername        = 'ops-es-cluster',
  $cluster_servers    = hiera('elk_stack_elastic_servers'),
  $version            = '2.3.2',
  $repo_version       = '2.x',
  $repo_manage        = true,
  $auto_upgrade       = false,
  $java_manage        = true,
  $java_pkg           = 'java-1.8.0-openjdk',
  $elastic_cert       = '/etc/elasticsearch/ssl/elastic.crt',
  $elastic_key        = '/etc/elasticsearch/ssl/elastic.key',
  $data_dir           = '/var/lib/es-data'

  ){

  class { 'elasticsearch':
    version           => $version,
    manage_repo       => $repo_manage,
    repo_version      => $repo_version,
    autoupgrade       => $auto_upgrade,
    java_install      => $java_manage,
    java_package      => $java_pkg,
    datadir           => $data_dir,
    config            => {
      'cluster.name' =>  $clustername,
      'discovery.zen.ping.multicast.enabled' => false,
      'discovery.zen.ping.unicast.hosts'     => $cluster_servers,
      'network.host' =>  $::ipaddress_eth1
    }
  }

  elasticsearch::instance { "ops-els":
    ssl               => true,
    ca_certificate    => "/etc/pki/ca-trust/source/anchors/elk_ca.crt",
    certificate       => $elastic_cert,
    private_key       => $elastic_key,
    keystore_path     => undef,
    keystore_password => "keystore_pass",
  }

  elasticsearch::plugin{ 'mobz/elasticsearch-head':
    instances  => 'ops-els'
  }
  
  elasticsearch::plugin{ 'lmenezes/elasticsearch-kopf':
    instances  => 'ops-els'
  }
  
  file { "/etc/elasticsearch/ssl" :
    ensure            => 'directory',
    owner             => 'root',
    group             => 'root',
    mode              => '0755',
  }

  file { $elastic_key:
    ensure            => file,
    owner             => 'root',
    group             => 'root',
    mode              => '0644',
    content           => hiera('elk_stack_elastic_key')
  }

  file { $elastic_cert:
    ensure            => file,
    owner             => 'root',
    group             => 'root',
    mode              => '0644',
    content           => hiera('elk_stack_elastic_cert')
  }

}

# vim: set ts=2 sw=2 et :
