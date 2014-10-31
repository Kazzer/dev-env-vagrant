# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

DEFAULT_USER = ENV["USERNAME"] or ENV["USER"]
PROVISIONED = File.file?(".vagrant/machines/default/virtualbox/id")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    if PROVISIONED
        config.ssh.username = "#{DEFAULT_USER}"
        config.ssh.private_key_path = "~/.ssh/id_rsa"
    end

    config.vm.box = "com.kadeem/tumbleweed64"
    config.vm.guest = :suse
    # config.vm.network "forwarded_port", guest: 80, host: 8080
    # config.vm.network "public_network"
    config.ssh.forward_agent = true
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.provider "virtualbox" do |vb|
        vb.cpus = 4
        vb.memory = 3072
    end
    config.vm.hostname = "ponyville.equestria"

    config.vm.provision "shell", inline: "echo $* >/tmp/DEFAULT_USER", args: "#{DEFAULT_USER}", privileged: false

    config.vm.provision "file", source: "scripts/common.sh", destination: "/tmp/vagrant/common.sh"

    config.vm.provision "file", source: "etc/motd", destination: "/tmp/root/etc/motd"
    config.vm.provision "file", source: "etc/skel", destination: "/tmp/root/etc/skel"
    config.vm.provision "shell", path: "scripts/init.sh"

    config.vm.provision "shell", path: "scripts/install_update_repos.sh"

    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["celestia", "We are gathered here today to once again honor the heroism of these six friends who stood up to the villain Discord and saved Equestria from eternal chaos.", "root", "", "Princess Celestia", "", "-d /root -M -o -r -u 0"]
    config.vm.provision "shell", path: "scripts/post_celestia.sh"

    config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "/tmp/root/home/#{DEFAULT_USER}/.ssh/id_rsa"
    config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/tmp/root/home/#{DEFAULT_USER}/.ssh/id_rsa.pub"
    config.vm.provision "shell", path: "scripts/user_default.sh"

    config.vm.provision "file", source: "etc/sudoers", destination: "/tmp/root/etc/sudoers"
    config.vm.provision "shell", path: "scripts/end.sh"
end
