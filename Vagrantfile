# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "com.kadeem/bottle64"
    config.vm.guest = :suse
    # config.vm.network "forwarded_port", guest: 80, host: 8080
    # config.vm.network "public_network"
    config.ssh.forward_agent = true
    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.vm.provider 'virtualbox' do |vb|
        vb.cpus = 4
        vb.memory = 3072
    end

    config.vm.provision 'file', source: 'scripts/common.sh', destination: '/tmp/vagrant/common.sh'
end
