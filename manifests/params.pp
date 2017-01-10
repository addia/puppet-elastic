# == Class: elastic::params
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
class elastic::params {
  $version                     = '2.3.2'
  $repo_version                = '2.x'
  $repo_manage                 = true
  $auto_upgrade                = false
  $java_manage                 = true
  $java_pkg                    = 'java-1.8.0-openjdk'
  $clustername                 = hiera('elk_stack_elastic_clustername')
  $instance                    = hiera('elk_stack_elastic_instance')
  $cluster_servers             = hiera('elk_stack_elastic_servers')
  $keystore_dir                = undef
  $keystore_passwd             = 'keystore_pass'
  $ssl_cacert_file             = '/etc/pki/ca-trust/source/anchors/webops-ca.crt'
  $elastic_cert                = '/etc/elasticsearch/ssl/elastic.crt'
  $elastic_key                 = '/etc/elasticsearch/ssl/elastic.key'
  $data_dir                    = '/var/lib/elasticsearch'
  $beats_dashboard             = 'beats-dashboards-1.2.3'
}

