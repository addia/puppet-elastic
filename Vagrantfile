# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.7.4"

Vagrant.configure(2) do |conf|
  conf.vm.box = "landregistry/centos"
  conf.vm.synced_folder ".yum", "/var/cache/yum"
  conf.vm.synced_folder ".gem", "/usr/local/share/gems/cache/"

  conf.vm.provision "shell", inline: <<-SCRIPT
    sed -i -e 's,keepcache=0,keepcache=1,g' /etc/yum.conf
    sed -i -e 's,#PermitRootLogin,PermitRootLogin,g' /etc/ssh/sshd_config
    cp /vagrant/tests/hosts.vagrant.conf /etc/hosts
    systemctl restart sshd
    yum install -y git
    yum install -y telnet
    puppet module install puppetlabs-stdlib
    puppet module install elasticsearch-elasticsearch
    puppet module install ceritsc-yum
    puppet module install puppetlabs-apt
    puppet module install puppetlabs-java
    puppet module install puppetlabs-java_ks
    puppet module install richardc-datacat
    puppet module install pcfens-ca_cert --version 1.3.0
    puppet module install camptocamp-openssl
    cd /etc/puppet/
    ln -s /vagrant/tests/hiera.vagrant.yaml /etc/puppet/hiera.yaml
    cd /etc/puppet/modules
    ln -s /vagrant /etc/puppet/modules/elastic
    puppet apply /vagrant/tests/init.pp
  SCRIPT

  conf.vm.define "server8" do |web|
    web.vm.host_name = "server8"
    web.vm.network "private_network", :ip => "192.168.42.56"
  end

  conf.vm.define "server9" do |web|
    web.vm.host_name = "server9"
    web.vm.network "private_network", :ip => "192.168.42.57"
  end

  conf.vm.define "server10" do |web|
    web.vm.host_name = "server10"
    web.vm.network "private_network", :ip => "192.168.42.58"
  end

  conf.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
    vb.customize ['modifyvm', :id, '--vram', ENV['VM_VIDEO'] || 24]
    vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
  end

end
