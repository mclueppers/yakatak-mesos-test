# Pre-requirements

Please complete task2 before continuing

# Install additional Master

Open Vagrantfile and add a second master server

```
            { :ip => "192.168.50.11", :hostname => "master2", :public_mac => "08002711DFF9", :private_mac => "08002711DFFA" }    
```
 
# Rebuild your Vagrant environment

```
$ vagrant destroy
$ vagrant up
```
