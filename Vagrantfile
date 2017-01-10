# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.define :addis_virt1 do |addis_virt1|
    addis_virt1.vm.box = "centos64"
    addis_virt1.vm.network :private_network, :ip => '192.168.122.51'
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "qemu"
    libvirt.host = "localhost"
    libvirt.connect_via_ssh = true
    libvirt.username = "root"
    libvirt.storage_pool_name = "virt-pool"
  end
end
