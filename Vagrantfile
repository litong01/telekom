# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

nodes = YAML.load_file("provisioning/nodes.conf.yml")
ids = YAML.load_file("provisioning/ids.conf.yml")


Vagrant.configure("2") do |config|
  config.vm.box = "tknerr/managed-server-dummy"
  config.vm.synced_folder "provisioning/", "/opt/provisioning"
  config.ssh.username = ids['username']
  config.ssh.password = ids['password']

  config.vm.define "mysqldb" do |mysqldb|
    mysqldb.vm.provider :managed do |managed|
      managed.server = nodes['mysqldb']['eth0']
    end

    mysqldb.vm.provision "install", type: "shell" do |s|
        s.path = "provisioning/install-mysqldb.sh"
    end
  end

end
