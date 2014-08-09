# First steps

The first task requires 3 Vagrant VMs

Create a folder of your choice:

```
$ mkdir -p task1
$ cd task1
$ vagrant init 
```

This creates a task1 folder and initializes the Vagrant environment. Next step is to convert it to multi-machine.

# Multi-machine specs

open Vagrantfile and set/comment out few default options:

```
  config.vm.box = "Official Ubuntu 14.04 daily Cloud Image amd64 (Development release,  No Guest Additions)"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  
  # Add public interface
  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # Add bootstrap.sh capability
  config.vm.provision :shell, path: "bootstrap.sh"
```

And before the closing end add:

```
  [ "master1", "slave1", "slave2" ].each do |hst|
    config.vm.define "#{hst}" do |node|
      node.vm.provision "shell",
        inline: "echo hello from node #{hst}"
      node.vm.hostname = "#{hst}"
    end
  end
```

The example above creates 3 nodes (master1, slave1 and slave2) and sets their hostname.

