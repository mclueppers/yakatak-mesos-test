# Pre-requirements

Please complete task2 before continuing

# Install additional Master

Open Vagrantfile and [add a second master](task3/Vagrantfile#L6) server

# Rebuild your Vagrant environment

```
$ vagrant destroy
$ vagrant up
```

# Management interfaces

Once the Vagrant environment is build (on my laptop it takes nearly 20 minutes) one can open the following management interfaces for:

* [Mesos Master](http://192.168.50.10:5050) - 192.168.50.10:5050
* [Marathon](http://192.168.50.10:8080) - 192.168.50.10:8080
* [Chronos](http://192.168.50.10:4400) - 192.168.50.10:4400

# Environment description

Vagrant creates 4 nodes - master1, master2, slave1, slave2

```
|             |                              Nodes                            |
|  Property   | ------------------------------------------------------------- |
|             |    master1    |    master2    |    slave1     |   slave2      |
| :---------- | :------------ | :------------ | :------------ | :------------ |
| Hostname    | mesos-master1 | mesos-master2 | mesos-slave1  | mesos-slave2  |
| IP          | 192.168.50.10 | 192.168.50.11 | 192.168.50.21 | 192.168.50.22 |
| Public MAC  | 08002711DFF7  | 08002711DFF9  | 08002711DFFB  | 08002711DFFD  |
| Private MAC | 08002711DFF8  | 08002711DFFA  | 08002711DFFC  | 08002711DFFE  |
```

! I'm setting fixed MAC addresses just not to deplete my DHCP server's lease range when testing Vagrant builds.

Each master node runs Mesos master and Zookeeper, Marathon and Chronos as well while every slave runs Mesos slave and Docker directly (non-geard). My research showed that although geard could make docker instances creation easier, Marathon runs better in direct mode, on other note I'm runnig my stack on Ubuntu and don't want to run Fedora soft.
