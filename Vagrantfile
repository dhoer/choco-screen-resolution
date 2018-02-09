# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "StefanScherer/windows_10"
  #config.vm.box = "StefanScherer/windows_2016"
  #config.vm.box = "mwrock/Windows2012R2"

  config.vm.network "forwarded_port", guest: 4444, host: 4444

  config.vm.provider "virtualbox" do |vb|
    vb.name = "Screen Resolution"
    vb.linked_clone = true
    vb.gui = true
    vb.memory = "2048"
  end

  # https://github.com/hashicorp/vagrant/issues/9138#issuecomment-342968348 -> privileged: false
  config.vm.provision "shell", path: "screen-resolution.ps1", privileged: false
  config.vm.provision "shell", path: "chrome-selenium-grid.ps1", privileged: false
  config.vm.provision "shell", inline: "choco install -y ruby --version 2.4.3.1", privileged: false
  config.vm.provision "shell", inline: "gem install bundler --no-document; cd C:\\vagrant; bundle update", privileged: false
end
