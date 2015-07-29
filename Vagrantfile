# -*- mode: ruby -*-
# vi: set ft=ruby :

# See Vagrantfile.example for additional options.
Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.provision "shell", path: "ubuntu-install.sh", privileged: true
end
