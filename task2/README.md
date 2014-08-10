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

# Configuration
masters = [ { :ip => "192.168.50.10", :hostname => "master1", :public_mac => "08002711DFF7", :private_mac => "08002711DFF8" } ]
slaves  = [ { :ip => "192.168.50.11", :hostname => "slave1", :public_mac => "08002711DFF9", :private_mac => "08002711DFFA" },
            { :ip => "192.168.50.12", :hostname => "slave2", :public_mac => "08002711DFFB", :private_mac => "08002711DFFC" },
]
mesos_ver = "0.19.1"

# Definitions
def is_master?(name)
   return /^master[0-9]/ =~ name
end

def is_slave?(name)
   return /^slave/ =~ name
end

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


  [ masters, slaves ].flatten.each_with_index do |nodeinfo, i|
    config.vm.define nodeinfo[:hostname] do |node|
      node.vm.provider "virtualbox" do |vb, override|

        override.vm.box = "ubuntu/trusty64"

        override.vm.hostname = "mesos-" + nodeinfo[:hostname]
        override.vm.network "private_network", ip: nodeinfo[:ip], mac: nodeinfo[:private_mac]
        override.vm.provision :hosts

        vb.name = 'mesos-' + nodeinfo[:hostname]
        # vb.gui = true
        vb.customize ["modifyvm", :id, "--memory", 1024, "--cpus", 2 ]

	# mesos-master doesn't create its work_dir.
	master_work_dir = "/var/run/mesos"
	if is_master?(nodeinfo[:hostname]) then
	    override.vm.provision :shell, :inline => "mkdir -p #{master_work_dir}"
	end

	override.vm.provision :chef_solo do |chef|
            # chef.log_level = :debug
            chef.add_recipe "apt"
            chef.add_recipe "mesos"

            if is_master?(nodeinfo[:hostname]) then
              chef.add_recipe "mesos::master"
              chef.json  = {
                :mesos=> {
                   :type         => "mesosphere",
                   :version      => "#{mesos_ver}",
                   :master_ips   => masters.map { |m| "#{m[:ip]}" },
                   :slave_ips    => slaves.map { |s| "#{s[:ip]}" },
		   :mesosphere   => {
		       :with_zookeeper => true
		   },
                   :master       => {
                       :cluster => "MyFirstMesosCluster",
                       :quorum => "#{(masters.length.to_f/2).ceil}",
                       :work_dir => master_work_dir,
                       :zk => "zk://192.168.50.10:2181/mesos",
                       :ip => "#{nodeinfo[:ip]}"
                   }
                }
              }
            elsif is_slave?(nodeinfo[:hostname]) then
	      chef.add_recipe "docker::aufs"
	      chef.add_recipe "docker::lxc"
	      chef.add_recipe "docker"
	      chef.add_recipe "mesos::slave"
	      chef.add_recipe "mesos::docker-executor"
	      chef.json = {
	          :mesos => {
	              :type         => "mesosphere",
		      :version      => "#{mesos_ver}",
		      :slave        => {
		          :master       => "zk://192.168.50.10:2181/mesos",
			  :ip           => "#{nodeinfo[:ip]}",
			  :isolation    => "process"
		      }
		  }
	       }
	     end
	  end

        if is_master?(nodeinfo[:hostname]) then
            override.vm.provision :shell, :inline => "sudo apt-get -y install marathon; sudo stop marathon; sudo start marathon"
            override.vm.provision :shell, :inline => "sudo apt-get -y install chronos; sudo stop chronos; sudo start chronos"
        end

	override.vm.network "public_network", type: "dhcp", mac: nodeinfo[:public_mac], bridge: "en1: Wi-Fi (AirPort)"
	override.vm.provision :shell, :inline => <<SCRIPT
    sed -n '/127.0.1.1/!p' -i /etc/hosts
SCRIPT
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
