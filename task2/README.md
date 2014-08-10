# Pre-requirements

Please complete task1 before continuing

# Install Marathon on Master

Open Vagrantfile and add the following at line 53 just before SCRIPT

```
    sudo apt-get install marathon
```
 
# Install Docker on the Slaves

Docker installation is handled by Chef too so change your slave definitions and add:

```
          chef.add_recipe "docker::aufs"
          chef.add_recipe "docker::lxc"
          chef.add_recipe "docker"
          chef.add_recipe "mesos::docker-executor"
```

In the end your Vagrantfile should look like this

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Add bootstrap.sh capability
  config.vm.provision :shell, path: "bootstrap.sh"

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "site.pp"
  # end

  # enable plugins
  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  # if you want to use vagrant-cachier,
  # please install vagrant-cachier plugin.
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.enable :apt
    config.cache.enable :chef
  end


  [ "master1", "slave1", "slave2" ].each do |hst|
    config.vm.define "#{hst}" do |node|
      node.vm.provider "virtualbox" do |vb, override|

        override.vm.box = "ubuntu/trusty64"

        override.vm.hostname = "mesos-#{hst}"
        override.vm.provision :hosts

        case "#{hst}"
          when /^master1$/
            override.vm.network "public_network", type: "dhcp", mac: "08002711DFF7", bridge: "en1: Wi-Fi (AirPort)"
            override.vm.network "private_network", ip: "192.168.50.10", mac: "08002711DFF8"
            vb.gui = true

            override.vm.provision :shell, :inline => <<SCRIPT
    sed -n '/127.0.1.1/!p' -i /etc/hosts
    sudo apt-get install marathon
SCRIPT

            override.vm.provision :chef_solo do |chef|
              # chef.log_level = :debug
              chef.add_recipe "apt"
              chef.add_recipe "mesos"

              chef.add_recipe "mesos::master"
              chef.json  = {
                :mesos=> {
                  :type         => "mesosphere",
                  :version      => "0.19.1",
                  :master_ips   => [ "192.168.50.10"],
                  :slave_ips    => [ "192.168.50.11", "192.168.50.12"],
                  :mesosphere   => {
                     :with_zookeeper => true
                  },
                  :master       => {
                     :cluster => "MyFirstMesosCluster",
                     :zk => "zk://192.168.50.10:2181/mesos",
                     :quorum => "1",
                     :work_dir => "/var/lib/mesos",
                     :ip => "192.168.50.10"
                  }
                }
              }
            end

          when /^slave1$/
            override.vm.network "public_network", type: "dhcp", bridge: "en1: Wi-Fi (AirPort)", :mac => "08002711DFF9"
            override.vm.network "private_network", ip: "192.168.50.11", :mac => "08002711DFFA"
            override.vm.provision :shell, :inline => <<SCRIPT
    sed -n '/127.0.1.1/!p' -i /etc/hosts
SCRIPT
            override.vm.provision :chef_solo do |chef|
              # chef.log_level = :debug
              chef.add_recipe "apt"
              chef.add_recipe "mesos"

              chef.add_recipe "docker::aufs"
              chef.add_recipe "docker::lxc"
              chef.add_recipe "docker"
              chef.add_recipe "mesos::slave"
              chef.add_recipe "mesos::docker-executor"
              chef.json  = {
                :mesos=> {
                  :type         => "mesosphere",
                  :version      => "0.19.1",
                  :slave        => {
                     :master    => "zk://192.168.50.10:2181/mesos",
                     :ip        => "192.168.50.11",
                     :isolation => "process"
                  }
                }
              }
            end

         when /^slave2$/
            override.vm.network "public_network", type: "dhcp", bridge: "en1: Wi-Fi (AirPort)", :mac => "08002711DFFB"
            override.vm.network "private_network", ip: "192.168.50.12", :mac => "08002711DFFC"
            override.vm.provision :shell , :inline => <<SCRIPT
    sed -n '/127.0.1.1/!p' -i.bak /etc/hosts
SCRIPT
        end

            override.vm.provision :chef_solo do |chef|
              # chef.log_level = :debug
              chef.add_recipe "apt"
              chef.add_recipe "mesos"

              chef.add_recipe "docker::aufs"
              chef.add_recipe "docker::lxc"
              chef.add_recipe "docker"
              chef.add_recipe "mesos::slave"
              chef.add_recipe "mesos::docker-executor"
              chef.json  = {
                :mesos=> {
                  :type         => "mesosphere",
                  :version      => "0.19.1",
                  :slave        => {
                     :master    => "zk://192.168.50.10:2181/mesos",
                     :ip        => "192.168.50.12",
                     :isolation => "process"
                  }
                }
              }
            end

        vb.name = 'mesos-' + "#{hst}"
        # vb.gui = true
        vb.customize ["modifyvm", :id, "--memory", 1024, "--cpus", 2 ]
      end
    end
  end
end
```

# Rebuild your Vagrant environment

```
$ vagrant destroy
$ vagrant up
```
