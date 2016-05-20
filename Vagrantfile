# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.7.4"
Vagrant.configure(2) do | global |
  global.vbguest.auto_update = false
end

Vagrant.configure(2) do |config|
  config.vm.box = "landregistry/centos"
  config.vm.provision "shell", inline: <<-SCRIPT
    yum install -y git
    puppet module install puppetlabs-vcsrepo
    puppet module install puppetlabs-stdlib
    ln -s /vagrant /etc/puppet/modules/elastic
    gem install librarian-puppet
    cd /vagrant
    /usr/local/bin/librarian-puppet install
    puppet apply --modulepath=/vagrant/modules:/etc/puppet/modules /etc/puppet/modules/elastic/tests/init.pp
  SCRIPT

  config.vm.network "private_network", :ip => "192.168.42.112"

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || 2048]
    vb.customize ['modifyvm', :id, '--vram', ENV['VM_VIDEO'] || 24]
    vb.customize ["modifyvm", :id, "--cpus", ENV['VM_CPUS'] || 4]
  end
end
