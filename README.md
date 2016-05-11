# Land Registry's Elastic Install

A puppet module to manage the install of Elastic search at the Land Registry

## Requirements

* Puppet  >=  3.4
* The [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) Puppet library.
* The [elasticsearch](https://forge.puppetlabs.com/elasticsearch/elasticsearch) Elasticsearch module.

## Usage

### Main class

```
class ( 'elastic' )

https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster.html
http://tecadmin.net/install-elasticsearch-multi-node-cluster-on-linux/#
http://devopscube.com/how-to-setup-an-elasticsearch-cluster/

edit the /etc/elasticsearch/elasticsearch.yml to match ( not yet in puppet )

checking with:  http://<elastic-vip:9200/_plugin/head/


```
### Message Management

```

```

### License

Please see the [LICENSE](https://github.com/LandRegistry-Ops/puppet-elastic/blob/master/LICENSE.md) file.

