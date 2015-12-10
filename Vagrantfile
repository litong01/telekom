# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

nodes = YAML.load_file("provisioning/nodes.dev.conf.yml")
ids = YAML.load_file("provisioning/ids.conf.yml")


Vagrant.configure("2") do |config|
  config.vm.box = "tknerr/managed-server-dummy"
  config.ssh.username = ids['username']
  config.ssh.password = ids['password']

  # database server setup
  config.vm.define "mysqldb" do |mysqldb|
    mysqldb.vm.provider :managed do |managed|
      managed.server = nodes['mysqldb']['eth0']
    end

    mysqldb.vm.provision "mysqldb-install", type: "shell" do |s|
        s.path = "provisioning/install-mysqldb.sh"
        s.args = ids['sys_password'] + ' ' + nodes['mysqldb']['eth1']
    end
  end

  # keystone setup
  config.vm.define "keystone" do |keystone|
    keystone.vm.provider :managed do |managed|
      managed.server = nodes['keystone']['eth0']
    end

    # rabbitmq is added on keystone machine, so we do rabbitmq setup
    # also in this block
    keystone.vm.provision "rabbitmq-install", type: "shell" do |s|
        s.path = "provisioning/install-rabbitmq.sh"
        s.args = ids['sys_password']
    end

    # keystone install
    keystone.vm.provision "keystone-install", type: "shell" do |s|
        s.path = "provisioning/install-keystone.sh"
        s.args = ids['sys_password'] + " " + nodes['keystone']['eth0']
    end
  end

  # glance setup
  config.vm.define "glance" do |glance|
    glance.vm.provider :managed do |managed|
      managed.server = nodes['glance']['eth0']
    end

    # glance install
    glance.vm.provision "glance-install", type: "shell" do |s|
        s.path = "provisioning/install-glance.sh"
        s.args = ids['sys_password'] + " " + nodes['glance']['eth0']
    end
  end

  # nova setup
  config.vm.define "nova" do |nova|
    nova.vm.provider :managed do |managed|
      managed.server = nodes['nova']['eth0']
    end

    # nova install
    nova.vm.provision "nova-install", type: "shell" do |s|
        s.path = "provisioning/install-nova.sh"
        s.args = ids['sys_password'] + " " + nodes['nova']['eth0'] + " " + nodes['nova']['eth1']
    end
  end

  # compute node setup
  compute_nodes = nodes.keys.select{|item| item.start_with?('compute')}
  compute_nodes.each do |key|
    config.vm.define "#{key}" do |node|
      node.vm.provider :managed do |managed|
        managed.server = nodes[key]['eth0']
      end

      node.vm.provision "compute-install", type: "shell" do |s|
        s.path = "provisioning/install-compute.sh"
        s.args = ids['sys_password'] + " " + nodes[key]['eth0'] + " " + nodes[key]['eth1']
      end
    end
  end
end
