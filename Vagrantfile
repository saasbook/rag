# -*- mode: ruby -*-
# vi: set ft=ruby :

# See Vagrantfile.example for additional options.
Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise64"

  config.vm.synced_folder "../rag", "/home/vagrant/rag"
  config.vm.synced_folder "../hw", "/home/vagrant/hw"
  config.vm.synced_folder "../rottenpotatoes", "/home/vagrant/rottenpotatoes"

  config.vm.provision "shell", path: "ubuntu-install.sh", privileged: false
end
