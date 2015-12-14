# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

nodes = YAML.load_file("provisioning/nodes.dev.conf.yml")
ids = YAML.load_file("provisioning/ids.conf.yml")


Vagrant.configure("2") do |config|
  config.vm.box = "tknerr/managed-server-dummy"
  config.ssh.username = ids['username']
  config.ssh.password = ids['password']

  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder "onvm", "/onvm", disabled: false, create: true

  # database server setup
  config.vm.define "mysqldb" do |mysqldb|
    mysqldb.vm.provider :managed do |managed|
      managed.server = nodes['mysqldb']['eth0']
    end

    mysqldb.vm.provision "mysqldb-install", type: "shell" do |s|
        s.path = "onvm/scripts/install/install-mysqldb.sh"
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
        s.path = "onvm/scripts/install/install-rabbitmq.sh"
        s.args = ids['sys_password']
    end

    # keystone install
    keystone.vm.provision "keystone-install", type: "shell" do |s|
        s.path = "onvm/scripts/install/install-keystone.sh"
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
        s.path = "onvm/scripts/install/install-glance.sh"
        s.args = ids['sys_password'] + " " + nodes['glance']['eth0']
    end
  end

  # cinder setup
  config.vm.define "cinder" do |cinder|
    cinder.vm.provider :managed do |managed|
      managed.server = nodes['cinder']['eth0']
    end

    # cinder install
    cinder.vm.provision "cinder-install", type: "shell" do |s|
        s.path = "onvm/scripts/install/install-cinder.sh"
        s.args = ids['sys_password'] + " " + nodes['cinder']['eth0'] + " " + nodes['cinder']['eth1']
    end
  end

  # neutron node setup
  config.vm.define "neutron" do |neutron|
    neutron.vm.provider :managed do |managed|
      managed.server = nodes['neutron']['eth0']
    end

    # neutron install
    neutron.vm.provision "neutron-install", type: "shell" do |s|
        s.path = "onvm/scripts/install/install-neutron.sh"
        s.args = ids['sys_password'] + " " + nodes['neutron']['eth0'] + " " + nodes['neutron']['eth1']
    end
  end

  # nova setup
  config.vm.define "nova" do |nova|
    nova.vm.provider :managed do |managed|
      managed.server = nodes['nova']['eth0']
    end

    # nova install
    nova.vm.provision "nova-install", type: "shell" do |s|
        s.path = "onvm/scripts/install/install-nova.sh"
        s.args = ids['sys_password'] + " " + nodes['nova']['eth0'] + " " + nodes['nova']['eth1']
    end
  end

  # horizon setup
  config.vm.define "horizon" do |horizon|
    horizon.vm.provider :managed do |managed|
      managed.server = nodes['horizon']['eth0']
    end

    # horizon install
    horizon.vm.provision "horizon-install", type: "shell" do |s|
        s.path = "onvm/scripts/install/install-horizon.sh"
        s.args = ids['sys_password'] + " " + nodes['horizon']['eth0'] + " " + nodes['horizon']['eth1']
    end
  end

  # heat setup
  config.vm.define "heat" do |heat|
    heat.vm.provider :managed do |managed|
      managed.server = nodes['heat']['eth0']
    end

    # heat install
    heat.vm.provision "heat-install", type: "shell" do |s|
        s.path = "onvm/scripts/install/install-heat.sh"
        s.args = ids['sys_password'] + " " + nodes['heat']['eth0'] + " " + nodes['heat']['eth1']
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
        s.path = "onvm/scripts/install/install-compute.sh"
        s.args = ids['sys_password'] + " " + nodes[key]['eth0'] + " " + nodes[key]['eth1']
      end

      # we will isntall cinder storage on each compute node as well
      node.vm.provision "cinder-storage-install", type: "shell" do |s|
        s.path = "onvm/scripts/install/install-cinder-storage.sh"
        s.args = ids['sys_password'] + " " + nodes[key]['eth0'] + " " + nodes[key]['eth1']
      end
    end
  end

  # do initial setup to create public and private network
  # all initialization should run on keystone node
  config.vm.define "init-node" do |node|
      node.vm.provider :managed do |managed|
        managed.server = nodes['keystone']['eth0']
      end

      node.vm.provision "init-node-01", type: "shell" do |s|
        s.path = "onvm/scripts/install/init-node-01.sh"
        s.args = ids['sys_password'] + " "
        s.args += ids['public_net']['id'] + " "
        s.args += ids['public_net']['start_ip'] + " "
        s.args += ids['public_net']['end_ip'] + " "
        s.args += ids['public_net']['gateway']
      end

      node.vm.provision "init-node-02", type: "shell" do |s|
        s.path = "onvm/scripts/install/init-node-02.sh"
        s.args = ids['sys_password']
      end
  end

end
