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


To setup a local ubuntu apt repository:
1. apt-get install apt-mirror apache2
2. config apt-mirror to use /apt-mirror directory by changing
   /etc/apt/mirror.list. Create a directory named /apt-mirror

      set base_path    /apt-mirror

3. then run apt-mirror which will take a day or two depends on your network
   speed. For a trusty ubuntu release, there will be around 140GB needed.

4. once all the packages have been downloaded, create links in /var/www/html
   directory and point to /apt-mirror subdirectories according to your
   settings, for example::
   
       ln -s /apt-mirror/mirror/archive.ubuntu.com/ubuntu ubuntu
       ln -s /apt-mirror/mirror/ubuntu-cloud.archive.canonical.com/ubuntu/ cubuntu

   The second one was to support openstack liberty packages.

5. For the machines which want to use this local apt repository, change the
   /etc/apt/source.list like the following::
   
      deb http://repoIP/ubuntu trusty main restricted universe multiverse
      deb http://repoIP/ubuntu trusty-security main restricted universe multiverse
      deb http://repoIP/ubuntu trusty-updates main restricted universe multiverse

      deb-src http://repoIP/ubuntu trusty main restricted universe multiverse
      deb-src http://repoIP/ubuntu trusty-security main restricted universe multiverse
      deb-src http://repoIP/ubuntu trusty-updates main restricted universe multiverse

      deb http://repoIP/cubuntu trusty-updates/liberty main
   
   Use your local apt repository server IP to replace repoIP in the above
   string, or setup repoIP in your /etc/hosts. 
   Do apt-get update, then you can install OpenStack as usual.
   
By default, ubuntu servers will have multiarchitecture enabled. To remove
these annoying apt-get update messages for i386 packages, do the following::

   dpkg --remove-architecture i386
