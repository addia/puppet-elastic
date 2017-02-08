# Land Registry's Elasticsearch Install

A puppet module to manage the install of Elasticsearch at the Land Registry

## Requirements

* A [Puppet](https://puppet.com/product/open-source-projects) Master server version 3.4 or later.
* The [stdlib](https://forge.puppet.com/puppetlabs/stdlib) Puppet library.
* The [elasticsearch](https://forge.puppet.com/elasticsearch/elasticsearch) Elasticsearch module.
* The [yum](https://forge.puppet.com/ceritsc/yum) Yum installer.
* The [apt](https://forge.puppet.com/puppetlabs/apt) Apt installer (dependency)
* The [java](https://forge.puppet.com/puppetlabs/java) Java module.
* The [java-ks](https://forge.puppet.com/puppetlabs/java_ks) Java keystore module.
* The [openssl](https://forge.puppet.com/camptocamp/openssl) OpenSSL module.
* The [ca-cert](https://forge.puppet.com/pcfens/ca_cert) CA certs installer.
* The [datacat](https://forge.puppet.com/richardc/datacat) concatenating data module.

## Usage

##### Create a YAML file in the secrets repo inside the 'cluster' folder to build a server or a cluster for Elasticsearch using the following basic examples:

```

classes:
  - 'elastic'

elk_stack_elastic_clustername: "els-dev-cluster"

elk_stack_elastic_instance: "els-dev"

elk_stack_elastic_servers: ['192.168.42.56', '192.168.42.57', '192.168.42.58']

elk_stack_tls_protocol: "https"

elk_stack_do_housekeeping: true

elk_stack_days_to_keep: 30

elk_stack_index_prefix: ['logstash']

```

##### Explanations

| Variable | Description | Comments |
| ------------- |-------------|-------------|
|elk_stack_elastic_clustername | The elastic cluster or server name||
|elk_stack_elastic_instance | The elastic database instance name||
|elk_stack_elastic_servers | The hash of one or more server names | Working DNS is required!|
|elk_stack_tls_protocol | What protocoll to use, http or https||
|elk_stack_do_housekeeping | Enable housekeeping with "true" or none with "undef"||
|elk_stack_days_to_keep | The number of days to keep in the database||
|elk_stack_index_prefix | The hash of Elastic search indices||


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

##### Explanations:

elk_stack_elastic_key: openssl key file content
elk_stack_elastic_cert: openssl cert file content
root_ca_cert: openssl ca cert file content
The three fields can be empty "" if the server is set to http.


### Troubleshooting:

```
curl -XGET "http://<SERVER_IP>:9200/_nodes/_local?human&pretty"

curl -XGET "http://<SERVER_IP>:9200/_cluster/health?waitForStatus=green&pretty=true"

curl -XGET 'http://<SERVER_IP>:9200/_cluster/stats?human&pretty

```

### Documentation:

https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster.html
http://tecadmin.net/install-elasticsearch-multi-node-cluster-on-linux/#
http://devopscube.com/how-to-setup-an-elasticsearch-cluster/

checking with:  http://<elastic-vip:9200/_plugin/head/


```
### Message Management

```


### License

Please see the [LICENSE](https://github.com/LandRegistry-Ops/puppet-elastic/blob/master/LICENSE.md) file.

