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

els_java_package: "java-1.8.0-openjdk"

els_clustername: "test-cluster"

els_instance: "test-els"

els_servers: ['192.168.xx.xx']

els_index_prefix: ['logstash']

els_jvm_options: ['-Xms512m','-Xmx512m']


```

##### Explanations

| Variable | Description | Comments |
| --- | --- | --- |
|| ** Single server ** ||
|els_version | The elastic version to install
|els_java_package | The Java version to install
|els_elastic_clustername | The elastic cluster or server name
|els_elastic_instance | The elastic database instance name
|els_elastic_servers | The hash of one or more server names | Working DNS is required or IP address(es).
|els_index_prefix | The hash of Elastic search indices
|els_jvm_options | The Java memory settings
|| ** Cluster extras ** ||
|els_minimum_nodes | to prevent split brain situations set the minimum master nodes to 2 or (3/2)+1
|els_requires_nodes | the minimum nodes required before starting recoveryi node is 2 or (3/2)+1
|| ** Housekeeping extras ** ||
|els_do_housekeeping | Enable housekeeping with `true`
|els_days_to_keep | The number of days of data to keep in the database
|| ** SSL and TLS extras ** ||
|els_ssl_enable | `true` enables ssl
|els_tls_protocol | set to `https` to enable tls for the API
|els_elastic_key | the OpenSSL key in YAML style
|els_elastic_cert | the OpenSSL cert in YAML style
|root_ca_cert | the OpenSSL CA in YAML style 
|els_keystore_pass | The Java keystore pass phrase
|els_system_key | The X-Pack system key


##### Create a YAML file in the secrets repo inside the 'network_location' folder to provide a few variables for the server or cluster using the following basic examples:

```

# this is a self signed vagrant_development key.
# md5sum : a833b812125330a094178fe7ad20d591  vagrant_devel.key
#
elk_stack_elastic_key: |
  -----BEGIN RSA PRIVATE KEY-----
  bla bla bla
  -----END RSA PRIVATE KEY-----

# this is a self signed vagrant_development cert.
# md5sum : a28335250a72ef55e671b3db355ccc50  vagrant_devel.crt
#
elk_stack_elastic_cert: |
  -----BEGIN CERTIFICATE-----
  bla bla bla
  -----END CERTIFICATE-----

# this is a self sign root CA cert.
# md5sum : b19458bf253b9ddb1d1715af166e80bd  addis_cacert.pem
#
root_ca_cert: |
  -----BEGIN CERTIFICATE-----
  bla bla bla
  -----END CERTIFICATE-----

```

### Troubleshooting

```

Check that the server is started after initial install (before configuration):

curl -XGET "http://localhost:9200/"   or   curl -XGET "http://`hostname -i`:9200/"

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

-----

Check the server and cluster status with:

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
      "transport_address" : "192.168.122.190:9300",
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
                  "192.168.122.190",
                  "192.168.122.191",
                  "192.168.122.192"
                ]
              }
            }
          }
        },
        "action" : {
          "destructive_requires_name" : "true"
        },
( output cropped .... )


curl -XGET "http://`hostname -i`:9200/_cluster/health?pretty=true"                    
Sample output:
{
  "cluster_name" : "test-cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}


curl -XGET "http://`hostname -i`:9200/_cluster/stats?human&pretty"
Sample output:
{
  "_nodes" : {
    "total" : 3,
    "successful" : 3,
    "failed" : 0
  },
  "cluster_name" : "test-cluster",
  "timestamp" : 1488812499583,
  "status" : "green",
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
( output cropped .... )


curl -XGET "http://`hostname -i`:9200/_cluster/pending_tasks?pretty=true"
Sample output:
{
  "tasks" : [ ]
}
Normally a cluster completes tasks in fractions of a second. If the list is long there might be an issue ...

-----

Checking which one the MASTER node is:  (all fixes need to be made on the master node !!)

Print the node ID of the MASTER:

curl -s -XGET "http://`hostname -i`:9200/_cluster/state/master_node?human&pretty" | grep master_node | awk '{print $3}'
Sample output:  (this ID should be identical on all nodes, or else trouble...)
"aoW1tLANT8mUmOHQnHCObg"


Print the node ID of the current node:

curl -s -XGET "http://`hostname -i`:9200/_nodes/_local?human&pretty" | grep -A1 '\"nodes\"' | tail -1 | awk '{print $1}'
Sample output:  (these IDs should be unique unless it is the Master node, or else trouble...)
"kiBoevN9SEC97EF0Enky6A"  -  this is a cluster node
"aoW1tLANT8mUmOHQnHCObg"  -  this is the master node ( in this example )


```

### Documentation

https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster.html

http://tecadmin.net/install-elasticsearch-multi-node-cluster-on-linux/#

http://devopscube.com/how-to-setup-an-elasticsearch-cluster/



### Database and Index Management

```

Maniplating of indices, data, shards etc all need to be done on the master node !!  check above how to check !!

Deleting a index: 

list the indexes: curl -s -XGET  "http://`hostname -i`:9200/_cat/indices?v" | sort
delete a index: curl -XDELETE "http://`hostname -i`:9200/<one index from list above"

....   much more to list here

```


### License

Please see the [LICENSE](https://github.com/LandRegistry-Ops/puppet-elastic/blob/master/LICENSE.md) file.

