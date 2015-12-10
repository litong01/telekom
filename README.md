# developernet

This is the vagrant project to install openstack onto physical servers
The project uses vagrant plugin found here::

    https://github.com/tknerr/vagrant-managed-servers

Before running vagrant up, set the default provider like this

    export VAGRANT_DEFAULT_PROVIDER=managed

Then make sure that you have all the configuration done in provisioning
nodes.conf.yml or nodes.dev.conf.yml file depends on which environment
you will be working on. Also create an id file named ids.conf.yml and
place it in provisioning directory, here is an example of that file::

    ---
    username: "tong"

    password: "ps"

    sys_password: "openstack"


Once all the settings look good, you can run the following command to set
things up::

    vagrant up
    vagrant provision

If everything works as expected, you should have your OpenStack cloud
up running.