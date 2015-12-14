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
    username: "name"
    password: "pass"
    sys_password: "openstack"

    public_net:
      id: 192.168.1.0/24
      start_ip: 192.168.1.210
      end_ip: 192.168.1.219
      gateway: 192.168.1.1

The username and password should be the user name and password to log
in to your physical servers, the id should be able to configured to
automatically become root user. The sys_password will be the password
used for all your OpenStack service password.

The public net section should indicate how the public flat network should
be setup.

Once all the settings look good, you can run the following command to set
things up::

    vagrant up
    vagrant provision

If everything works as expected, you should have your OpenStack cloud
up running.