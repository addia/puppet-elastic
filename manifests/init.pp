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
#   keystore_dir       = leave as default
#   keystore_passwd    = java keystore password
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
  $version            = '5.2.0',
  $repo_version       = '5.x',
  $repo_manage        = true,
  $restart_on_change  = true,
  $auto_upgrade       = false,
  $java_install       = true,
  $tls_protocol       = hiera('elk_stack_tls_protocol'),
  $clustername        = hiera('elk_stack_elastic_clustername'),
  $instance           = hiera('elk_stack_elastic_instance'),
  $cluster_servers    = hiera('elk_stack_elastic_servers'),
  $setup_housekeep    = hiera('elk_stack_do_housekeeping'),
  $days_keep          = hiera('elk_stack_days_to_keep'),
  $index_prefix       = hiera('elk_stack_index_prefix'),
  $keystore_dir       = undef,
  $keystore_passwd    = 'keystore_pass',
  $ssl_cacert_file    = '/etc/pki/ca-trust/source/anchors/lr_rootca.crt',
  $elastic_cert       = '/etc/elasticsearch/ssl/elastic.crt',
  $elastic_key        = '/etc/elasticsearch/ssl/elastic.key',
  $data_dir           = '/var/lib/elasticsearch',
) {

  notify { "## --->>> Installing and configuring ${clustername}": }

  class { 'elasticsearch':
    version           => $version,
    manage_repo       => $repo_manage,
    repo_version      => $repo_version,
    restart_on_change => $restart_on_change,
    autoupgrade       => $auto_upgrade,
    java_install      => $java_install,
    datadir           => $data_dir,
    api_protocol      => $tls_protocol,
    api_ca_file       => $ssl_cacert_file,
    config            => {
      'cluster.name'                     => $clustername,
      'discovery.zen.ping.unicast.hosts' => $cluster_servers,
      }
    }

  elasticsearch::instance { $instance:
    ensure => 'present',
    status => 'running',
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

  if $::tls_protocol == 'https' {
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
      source => 'puppet:///modules/elastic/lr_rootca.crt',
      }
    }

  }


# -----------------------
# vim: set ts=2 sw=2 et :
