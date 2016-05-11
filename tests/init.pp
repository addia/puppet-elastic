
class { 'elasticsearch':
  version => '2.2.1',
  manage_repo  => true,
  repo_version => '2.x',
  config       => {
    'cluster.name'                         => 'ops-elk',
    'discovery.zen.ping.multicast.enabled' => false
    }
}

elasticsearch::instance { "$::hostname": }

elasticsearch::plugin{'mobz/elasticsearch-head':
  instances  => $::hostname
}
