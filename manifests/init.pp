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
#   version           = version to install
#   repo_version      = yum repo version
#   repo_manage       = 'true' for installing the yum.repo file
#   auto_upgrade      = 'false' for NOT to autoupgrade ES
#   java_manage       = 'true' for installing Java
#   java_pkg          = which java package to install
#   clustername       = the elasticsearch cluster name
#   instance          = the elasticsearch instance name
#   cluster_servers   = the servers addresses to configure the cluster
#   keystore_dir      = leave as default
#   keystore_passwd   = java keystore password
#   ssl_cacert_file   = the CA certificate for self signed certs
#   elastic_cert      = the certificate for the elastic cluster
#   elastic_key       = the private for the elastic cluster
#   data_dir          = directory for saving the ES data
#   beats_dashboard   = the filename and version of the zip file to download and install
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
  $beats_dashboard             = $elastic::params::beats_dashboard,
  $data_dir                    = $elastic::params::data_dir
) {

  include elastic::params

  notify { "## --->>> configuring package ${clustername}": }

    anchor { 'elastic::begin': } ->
    class { '::elastic::install': } ->
    class { '::elastic::config': } ~>
    anchor { 'elastic::end': }

}

# vim: set ts=2 sw=2 et :
