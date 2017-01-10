# == Class: elastic::config
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
class elastic::config (
  $clustername                 = $elastic::params::clustername,
  $cluster_servers             = $elastic::params::cluster_servers,
  $beats_dashboard             = $elastic::params::beats_dashboard,
  $data_dir                    = $elastic::params::data_dir
) {

  include elastic::params

  notify { "## --->>> Configuring indexes for ${clustername}": }

  if $::hostname == $cluster_servers[0] {
    download_uncompress {'beats-dashboards':
      distribution_name => "https://download.elastic.co/beats/dashboards/${beats_dashboard}.zip",
      dest_folder       => $data_dir,
      creates           => "${data_dir}/.beats_dash",
      uncompress        => 'zip',
      user              => 'elasticsearch',
      group             => 'elasticsearch',
      }

    download_uncompress {'beats-index':
      distribution_name => 'https://raw.githubusercontent.com/elastic/beats/master/filebeat/filebeat.template.json',
      dest_folder       => $data_dir,
      creates           => "${data_dir}/.filebeat_index",
      user              => 'elasticsearch',
      group             => 'elasticsearch',
      }
    }

  exec { 'Loading_beats-dash' :
    command => "cd ${data_dir}/${beats_dashboard}; ./load.sh -url http://${::hostname}:9200",
    onlyif  => "test -f ${data_dir}/${beats_dashboard}.zip",
    creates => "${data_dir}/.beats_dash",
    path    => '/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin/:/bin/:/sbin/',
    } ~>

  # Trap door to only allow plugin setup once
  file { "${data_dir}/.beats_dash" :
    ensure  => present,
    content => 'dashboard setup completed',
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
    mode    => '0644',
    }

  exec { 'Loading_beats-index' :
    command => "curl -XPUT 'http://${::hostname}:9200/_template/filebeat?pretty' -d@${data_dir}/filebeat-index-template.json",
    onlyif  => "test -f ${data_dir}/filebeat-index-template.json",
    creates => "${data_dir}/.filebeat_index",
    path    => '/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin/:/bin/:/sbin/',
    } ~>

  # Trap door to only allow plugin setup once
  file { "${data_dir}/.filebeat_index" :
    ensure  => present,
    content => 'index setup completed',
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
    mode    => '0644',
    }

  file { '/etc/cron.daily/remove_old_index':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    source => 'puppet:///modules/elastic/remove_old_index.sh'
    }

  }


# vim: set ts=2 sw=2 et :
