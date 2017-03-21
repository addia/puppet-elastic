#!/usr/bin/bash

updatedb
systemctl status elastic*
systemctl stop elastic*
yum -y remove elasticsearch
rm -rf /etc/elasticsearch /var/lib/elasticsearch /var/log/elasticsearch /var/lib/yum/repos/x86_64/7/elastic* /usr/share/elasticsearch /etc/systemd/system/multi-user.target.wants/elasticsearch.service /etc/sysconfig/elastic*  /etc/systemd/system/elastic* /opt/elasticsearch /usr/lib/sysctl.d/elasticsearch.conf /usr/lib/systemd/system/elastic*  /usr/lib/tmpfiles.d/elasticsearch.conf
updatedb
locate elasticsearch
