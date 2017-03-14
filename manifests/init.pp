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
#   java_package       = explicitly specify the java package i.E. java-1.8.0-openjdk
#   api_protocol       = specify either "http" or "https"
#   ssl_enable         = specify 'true' or "" (undef) to manage SSL set-up
#   system_key         = the system key for X-Pack goes here
#   tls_protocol       = the elasticsearch cluster is using http or https
#   clustername        = the elasticsearch cluster name
#   els_minimum_nodes  = to prevent split brain situations set the minimum master nodes to 2 or (3/2)+1
#   els_requires_nodes = the minimum nodes required before starting recovery mode is 2 or (3/2)+1
#   data_ipaddress     = automatically eth1 if available
#   instance           = the elasticsearch instance name
#   cluster_servers    = the servers addresses to configure the cluster
#   setup_housekeep    = set to true/undef to set-up houskeeping
#   days_keep          = days to keep in the ELS database after houskeeping
#   index_prefix       = the array of indices to run the housekeeping against
#   keystore_pass      = java keystore password
#   jvm_options        = set-up the JVM memory requirements i.E. ['-Xms512m','-Xmx512m']
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
  $java_package       = hiera('els_java_package'),
  $api_protocol       = hiera('els_api_protocol','http'),
  $ssl_enable         = hiera('els_ssl_enable',undef),
  $system_key         = hiera('els_system_key',undef),
  $clustername        = hiera('els_clustername'),
  $els_minimum_nodes  = hiera('els_minimum_nodes',1),
  $els_requires_nodes = hiera('els_requires_nodes',1),
  $instance           = hiera('els_instance'),
  $cluster_servers    = hiera('els_servers'),
  $setup_housekeep    = hiera('els_do_housekeeping',undef),
  $days_keep          = hiera('els_days_to_keep',30),
  $index_prefix       = hiera('els_index_prefix'),
  $keystore_pass      = hiera('els_keystore_pass',undef),
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
    java_package      => $java_package,
    jvm_options       => $jvm_options,
    datadir           => $data_dir,
    api_protocol      => $api_protocol,
    api_ca_file       => $ssl_cacert_file,
    config            => {
      'cluster.name'                       => $clustername,
      'discovery.zen.ping.unicast.hosts'   => $cluster_servers,
      'network.host'                       => $data_ipaddress,
      'http.port'                          => 9200,
      'discovery.zen.minimum_master_nodes' => $els_minimum_nodes,
      'gateway.recover_after_nodes'        => $els_requires_nodes,
      'action.destructive_requires_name'   => true,
    }
  }

  # notify { "## --->>> Configuring instance ${::ssl_enable}": }
  if $::ssl_enable {
    elasticsearch::instance { $instance:
      ensure            => 'present',
      status            => 'running',
      ssl               => $ssl_enable,
      ca_certificate    => $ssl_cacert_file,
      certificate       => $elastic_cert,
      private_key       => $elastic_key,
      keystore_password => $keystore_pass,
      system_key        => $system_key,
    }
    elasticsearch::plugin { 'x-pack':
      instance          => $instance,
    }
  } else {
    elasticsearch::instance { $instance:
      ensure => 'present',
      status => 'running',
    }
  }

  # notify { "## --->>> Configuring Housekeeping ${::setup_housekeep}": }
  if $::setup_housekeep {
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
      content => hiera('els_elastic_key')
    }

    file { $elastic_cert:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => hiera('els_elastic_cert')
    }

    ca_cert::ca { 'lr_rootca':
      ensure => 'trusted',
      source => hiera('root_ca_cert')
    }
  }

}


# -----------------------
# vim: set ts=2 sw=2 et :
