# Land Registry's Elastic Install

A puppet module to manage the install of Elastic search at the Land Registry

## Requirements

* Puppet  >=  3.4
* The [stdlib](https://forge.puppet.com/puppetlabs/stdlib) Puppet library.
* The [elasticsearch](https://forge.puppet.com/elasticsearch/elasticsearch) Elasticsearch module.
* The [yum](https://forge.puppet.com/ceritsc/yum) Yum installer.
* The [apt](https://forge.puppet.com/puppetlabs/apt) Apt installer (dependency)
* The [java](https://forge.puppet.com/puppetlabs/java) Java module.
* The [java-ks](https://forge.puppet.com/puppetlabs/java_ks) Java keystore module.
* The [openssl](https://forge.puppet.com/camptocamp/openssl) OpenSSL module.
* The [ca-cert](https://forge.puppet.com/pcfens/ca_cert) CA certs installer.
* The [datacat](https://forge.puppet.com/richardc/datacat) Data manipulating module.

## Usage

### Main class

```
class ( 'elastic' )

https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster.html
http://tecadmin.net/install-elasticsearch-multi-node-cluster-on-linux/#
http://devopscube.com/how-to-setup-an-elasticsearch-cluster/

checking with:  http://<elastic-vip:9200/_plugin/head/


```
### Message Management

```

```

### License

Please see the [LICENSE](https://github.com/LandRegistry-Ops/puppet-elastic/blob/master/LICENSE.md) file.

