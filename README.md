# Land Registry's Elasticsearch Install

A puppet module to manage the install of Elasticsearch at the Land Registry

## Requirements

* A [Puppet](https://puppet.com/product/open-source-projects) Master server version 3.8.
* The [stdlib](https://forge.puppet.com/puppetlabs/stdlib) Puppet library version 4.15.0.
* The [elasticsearch](https://forge.puppet.com/elastic/elasticsearch) Elasticsearch module version 5.1.0.
* The [yum](https://forge.puppet.com/puppet/yum) Yum installer version 0.10.0 (last version for Puppet 3.8).
* The [apt](https://forge.puppet.com/puppetlabs/apt) Apt installer version 2.3.0 (dependency)
* The [java](https://forge.puppet.com/puppetlabs/java) Java module version 1.6.0.
* The [java-ks](https://forge.puppet.com/puppetlabs/java_ks) Java keystore module version 1.4.1.
* The [openssl](https://forge.puppet.com/camptocamp/openssl) OpenSSL module version 1.9.0.
* The [ca-cert](https://forge.puppet.com/pcfens/ca_cert) CA certs installer version 1.3.0 (newer versions fail in Puppet 3.8).
* The [datacat](https://forge.puppet.com/richardc/datacat) concatenating data module version 0.6.2.

## Usage

##### Create a YAML file in the secrets repo inside the 'cluster' folder to build a server or a cluster for Elasticsearch using the following basic examples:

```

classes:
  - 'elastic'

els_version: "5.2.2"

els_clustername: "test-cluster"

els_instance: "test-els"

els_servers: ['192.168.xx.xx']

els_index_prefix: ['logstash']

els_jvm_options: ['-Xms512m','-Xmx512m']


```

##### Explanations of all mandatory and optional hiera variables

| Variable | Description | Comments |
| --- | --- | --- |
| **Single server** | --- | --- |
| els_version | The elastic version to install
| els_elastic_clustername | The elastic cluster or server name
| els_elastic_instance | The elastic database instance name
| els_elastic_servers | The hash of one or more server names | Working DNS is required or IP address(es).
| els_index_prefix | The hash of Elastic search indices
| els_jvm_options | The Java memory settings
| **Java install** | --- | --- |
| els_java_install | Default is `true` if not included in your YAML file, set the `false` to ignore Java
| els_java_package | A specific Java version to install.
| **Cluster extras** | --- | --- |
| els_minimum_nodes | to prevent split brain situations set the minimum master nodes to 2 in a three way cluster or do the math `(<no of servers>/2)+1`
| els_requires_nodes | the minimum nodes required before starting recovery node is 2 in a three way cluster or do the math `(<no of servers>/2)+1`
| **Housekeeping extras** | --- | --- |
| els_do_housekeeping | Enable housekeeping with `true`
| els_days_to_keep | The number of days of data to keep in the database
| **SSL and TLS extras** | --- | --- |
| els_ssl_enable | `true` enables ssl
| els_tls_protocol | set to `https` to enable tls for the API
| els_elastic_key | the OpenSSL key in YAML style
| els_elastic_cert | the OpenSSL cert in YAML style
| root_ca_cert | the OpenSSL CA in YAML style
| els_keystore_pass | The Java keystore pass phrase
| els_system_key | The X-Pack system key


##### When SSL and/or x-pack is required create a YAML file in the secrets repo inside the 'network_location' folder to provide the cwcertificate variables for the server or cluster using the following basic examples:

```

# this is the LR signed Elastic key.
# md5sum : a833b812125330a094178fe7ad20d591  elastic.key
#
els_elastic_key: |
  -----BEGIN RSA PRIVATE KEY-----
  bla bla bla
  -----END RSA PRIVATE KEY-----

# this is the LR signed Elastic cert.
# md5sum : a28335250a72ef55e671b3db355ccc50  elastic.crt
#
els_elastic_cert: |
  -----BEGIN CERTIFICATE-----
  bla bla bla
  -----END CERTIFICATE-----

# this is the LR sign root CA cert.
# md5sum : b19458bf253b9ddb1d1715af166e80bd  root_cacert.pem
#
root_ca_cert: |
  -----BEGIN CERTIFICATE-----
  bla bla bla
  -----END CERTIFICATE-----

els_keystore_pass: "stuff"

els_system_key: "stuff"

```

### Troubleshooting

Check that the server is started after initial install:

```

curl -XGET "http://`hostname -i`:9200/"

If this command doesn't work of only works with `localhost`, your JVM settings are wrong.

You sould see this output with similar values:
{
  "name" : "kiBoevN",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "tWmf_rm0Q8iTcrzgwaXeNw",
  "version" : {
    "number" : "5.2.2",
    "build_hash" : "f9d9b74",
    "build_date" : "2017-02-24T17:26:45.835Z",
    "build_snapshot" : false,
    "lucene_version" : "6.4.1"
  },
  "tagline" : "You Know, for Search"
}

```

Check that all ports are configured correctly:

```

netstat -ltnp

You should see these port plus maybe others:

root@hh-els-c01 [/home/lrtm548] > netstat -ltnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/systemd
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1199/sshd
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      1717/master
tcp        0      0 0.0.0.0:5666            0.0.0.0:*               LISTEN      5718/nrpe
tcp6       0      0 :::111                  :::*                    LISTEN      1/systemd
tcp6       0      0 10.79.0.80:9200         :::*                    LISTEN      748/java            <<<   elastic
tcp6       0      0 10.79.0.80:9300         :::*                    LISTEN      748/java            <<<   elastic
tcp6       0      0 :::22                   :::*                    LISTEN      1199/sshd
tcp6       0      0 ::1:25                  :::*                    LISTEN      1717/master
tcp6       0      0 :::5666                 :::*                    LISTEN      5718/nrpe


```

Check the server and cluster status with:

```

curl -XGET "http://`hostname -i`:9200/_nodes/_local?human&pretty"

You sould see this output with similar values:
{
  "_nodes" : {
    "total" : 1,
    "successful" : 1,
    "failed" : 0
  },
  "cluster_name" : "test-cluster",
  "nodes" : {
    "vwSCxd_fSnmM8VC9mErjMw" : {
      "name" : "elastic1",
      "transport_address" : "192.168.122.190:9300",                    <<<  important for clustering
      "host" : "192.168.122.190",
      "ip" : "192.168.122.190",
      "version" : "5.2.2",
      "build_hash" : "f9d9b74",
      "total_indexing_buffer_in_bytes" : "203.1mb",
      "total_indexing_buffer" : 213005107,
      "roles" : [
        "master",
        "data",
        "ingest"
      ],
      "settings" : {
        "pidfile" : "/var/run/elasticsearch/elasticsearch.pid",
        "cluster" : {
          "name" : "test-cluster"
        },
        "node" : {
          "name" : "elastic1"
        },
        "path" : {
          "conf" : "/etc/elasticsearch",
          "data" : [
            "/var/lib/elasticsearch"
          ],
          "logs" : "/var/log/elasticsearch",
          "home" : "/usr/share/elasticsearch"
        },
        "discovery" : {
          "zen" : {
            "minimum_master_nodes" : "2",
            "ping" : {
              "unicast" : {
                "hosts" : [
                  "192.168.122.190",                                   <<<  cluster node 1
                  "192.168.122.191",                                   <<<  cluster node 2
                  "192.168.122.192"                                    <<<  cluster node 3
                ]
              }
            }
          }
        },
        "action" : {
          "destructive_requires_name" : "true"
        },
( output cropped .... )                                                <<<  lots more blurb


```

Check the cluster health with:

```

curl -XGET "http://`hostname -i`:9200/_cluster/health?pretty=true"

You should see these this sample output:

{
  "cluster_name" : "test-cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,                                               <<<  number of nodes attached
  "number_of_data_nodes" : 3,                                          <<<  number of nodes containing shards
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0                            <<< Do get worried if it is not 100% !!!
}


```

Check the cluster status with command as ELS 5.x is lacking a GUI:

```

curl -XGET "http://`hostname -i`:9200/_cluster/stats?human&pretty"

This sample output is from a healthy elastic cluster:

{
  "_nodes" : {
    "total" : 3,                                                       <<< configured cluster nodes
    "successful" : 3,                                                  <<< connected cluster nodes
    "failed" : 0                                                       <<< failed nodes
  },
  "cluster_name" : "test-cluster",
  "timestamp" : 1488812499583,
  "status" : "green",                                                  <<< green = OK ... else fix it !!!
  "indices" : {
    "count" : 0,
    "shards" : { },
    "docs" : {
      "count" : 0,
      "deleted" : 0
    },
    "store" : {
      "size" : "0b",
      "size_in_bytes" : 0,
      "throttle_time" : "0s",
      "throttle_time_in_millis" : 0
    },
    "fielddata" : {
      "memory_size" : "0b",
      "memory_size_in_bytes" : 0,
      "evictions" : 0
    },
    "query_cache" : {
      "memory_size" : "0b",
      "memory_size_in_bytes" : 0,
      "total_count" : 0,
      "hit_count" : 0,
      "miss_count" : 0,
      "cache_size" : 0,
      "cache_count" : 0,
      "evictions" : 0
    },
    "completion" : {
      "size" : "0b",
      "size_in_bytes" : 0
    },
( output cropped .... )                                                <<<  lots more blurb


```

Check the cluster task list with command as ELS 5.x is lacking a GUI:

```

curl -XGET "http://`hostname -i`:9200/_cluster/pending_tasks?pretty=true"

IThis is a healthy sample output:

{
  "tasks" : [ ]
}

Normally a cluster completes tasks in fractions of a second. If the list is long there might be an issue ...

-----

```

Checking and finding the current MASTER node:
Be aware, all fixes need to be made on the master node, or else you could be asking for trouble !!!

Everry cluster member should print the same Master ID, or the server is not member of the cluster you think it should.

```

Print the node ID of the MASTER:

curl -s -XGET "http://`hostname -i`:9200/_cluster/state/master_node?human&pretty" | grep master_node | awk '{print $3}'

Sample current master ID:

"aoW1tLANT8mUmOHQnHCObg"


Print the unique node ID of the current node:

curl -s -XGET "http://`hostname -i`:9200/_nodes/_local?human&pretty" | grep -A1 '\"nodes\"' | tail -1 | awk '{print $1}'

Sample output:

"kiBoevN9SEC97EF0Enky6A"  -  this is a cluster member node


```

### Database and Index Management

Maniplating of indices, data, shards etc all need to be done on the master node !!  check above how to check !!


```

Deleting a index:

list the indexes: curl -s -XGET  "http://`hostname -i`:9200/_cat/indices?v" | sort
delete a index: curl -XDELETE "http://`hostname -i`:9200/<one_index_from_list_above"

....   much more to list here

```



### Documentation (always a good read ...)

https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster.html

http://tecadmin.net/install-elasticsearch-multi-node-cluster-on-linux/#

http://devopscube.com/how-to-setup-an-elasticsearch-cluster/




### License

Please see the [LICENSE](https://github.com/LandRegistry-Ops/puppet-elastic/blob/master/LICENSE.md) file.

