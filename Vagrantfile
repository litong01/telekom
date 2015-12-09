# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

nodes = YAML.load_file("provisioning/nodes.conf.yml")
ids = YAML.load_file("provisioning/ids.conf.yml")


Vagrant.configure("2") do |config|
  config.vm.box = "tknerr/managed-server-dummy"
  config.ssh.username = ids['username']
  config.ssh.password = ids['password']

  config.vm.define "mysqldb" do |mysqldb|
    mysqldb.vm.provider :managed do |managed|
      managed.server = nodes['mysqldb']['eth0']
    end

    mysqldb.vm.provision "mysqldb-install", type: "shell" do |s|
        s.path = "provisioning/install-mysqldb.sh"
        s.args = ids['sys_password'] + ' ' + nodes['mysqldb']['eth1']
    end
  end

  config.vm.define "keystone" do |keystone|
    keystone.vm.provider :managed do |managed|
      managed.server = nodes['keystone']['eth0']
    end

    keystone.vm.provision "rabbitmq-install", type: "shell" do |s|
        s.path = "provisioning/install-rabbitmq.sh"
        s.args = ids['sys_password']
    end

    keystone.vm.provision "keystone-install", type: "shell" do |s|
        s.path = "provisioning/install-keystone.sh"
        s.args = ids['sys_password']
    end

  end

end
