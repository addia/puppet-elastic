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
#   version            = Elastic version to install
#   repo_version       = Elastic rpm repo version
#   repo_manage        = 'true' for letting puppet manage the repo file
#   restart_on_change  = 'true' otherwise the resource will mask the process ...   :-(
#   auto_upgrade       = 'false' for NOT EVER to autoupgrade Elastic
#   java_install       = 'true' for installing the correct Java version
#   tls_protocol       = the elasticsearch cluster is using http or https
#   clustername        = the elasticsearch cluster name
#   instance           = the elasticsearch instance name
#   cluster_servers    = the servers addresses to configure the cluster
#   setup_housekeep    = set to true/undef to set-up houskeeping
#   days_keep          = days to keep in the ELS database after houskeeping
#   index_prefix       = the array of indices to run the housekeeping against
#   keystore_pass      = java keystore password
#   ssl_cacert_file    = the CA certificate for self signed certs
#   elastic_cert       = the certificate for the elastic cluster
#   elastic_key        = the private for the elastic cluster
#   data_dir           = directory for saving the ES data
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
# Copyright:  ©  2017  LR / Addi.
#
#
class elastic (
  $version            = hiera('els_version'),
  $repo_version       = '5.x',
  $repo_manage        = true,
  $restart_on_change  = true,
  $auto_upgrade       = false,
  $java_install       = true,
  $java_version       = hiera('els_java_version'),
  $api_protocol       = hiera('els_api_protocol'),
  $ssl_enable         = hiera('els_ssl_enable'),
  $clustername        = hiera('els_clustername'),
  $els_minimum_nodes  = hiera('els_minimum_nodes'),
  $els_requires_nodes = hiera('els_requires_nodes'),
  $instance           = hiera('els_instance'),
  $cluster_servers    = hiera('els_servers'),
  $setup_housekeep    = hiera('els_do_housekeeping'),
  $days_keep          = hiera('els_days_to_keep'),
  $index_prefix       = hiera('els_index_prefix'),
  $keystore_pass      = hiera('els_keystore_pass'),
  $jvm_options        = hiera('els_jvm_options'),
  $ssl_cacert_file    = '/etc/pki/ca-trust/source/anchors/lr_rootca.crt',
  $elastic_cert       = '/etc/elasticsearch/ssl/elastic.crt',
  $elastic_key        = '/etc/elasticsearch/ssl/elastic.key',
  $data_dir           = '/var/lib/elasticsearch',
) {

  notify { "## --->>> Installing and configuring ${clustername}": }

  # set the data network
  if ($::ipaddress_eth1 != undef) {
    $data_ipaddress = $::ipaddress_eth1
  } else {
    $data_ipaddress = $::ipaddress_eth0
  }

  class { 'elasticsearch':
    version           => $version,
    manage_repo       => $repo_manage,
    repo_version      => $repo_version,
    restart_on_change => $restart_on_change,
    autoupgrade       => $auto_upgrade,
    java_install      => $java_install,
    java_package      => "java-${java_version}",
    jvm_options       => $jvm_options,
    datadir           => $data_dir,
    api_protocol      => $api_protocol,
    api_ca_file       => $ssl_cacert_file,
    config            => {
      'cluster.name'                       => $clustername,
      'discovery.zen.ping.unicast.hosts'   => $cluster_servers,
      'network.host'                       => $data_ipaddress,
      'discovery.zen.minimum_master_nodes' => $els_minimum_nodes,
      'gateway.recover_after_nodes'        => $els_requires_nodes,
      'action.destructive_requires_name'   => true,
    }
  }

  if $::ssl_enable {
    elasticsearch::instance { $instance:
      ensure            => 'present',
      status            => 'running',
      ssl               => $ssl_enable,
      ca_certificate    => $ssl_cacert_file,
      certificate       => $elastic_cert,
      private_key       => $elastic_key,
      keystore_password => $keystore_pass,
    }
  } else {
    elasticsearch::instance { $instance:
      ensure => 'present',
      status => 'running',
    }
  }

  if $::setup_housekeep {
    # Set-up a housekeeping job
    file { '/usr/local/bin/remove_old_index.sh' :
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('elastic/remove_old_index_sh.erb'),
    }

    # Set backup cron job
    cron { 'els_housekeeping':
      ensure  => present,
      command => '/usr/local/bin/remove_old_index.sh',
      hour    => 22,
      minute  => 15,
      user    => root
    }
  } else {
    cron { 'els_housekeeping':
      ensure => absent,
    }
  }

  if $::ssl_enable {
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

    ca_cert::ca { 'lr_rootca':
      ensure => 'trusted',
      source => hiera('root_ca_cert')
    }
  }

}


# -----------------------
# vim: set ts=2 sw=2 et :
