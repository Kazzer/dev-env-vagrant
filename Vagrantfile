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
    config.vm.provision "file", source: "etc/init.d", destination: "/tmp/root/etc/init.d"
    config.vm.provision "file", source: "etc/skel", destination: "/tmp/root/etc/skel"
    config.vm.provision "shell", path: "scripts/init.sh"

    config.vm.provision "shell", path: "scripts/install_update_repos.sh"

    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["celestia", "We are gathered here today to once again honor the heroism of these six friends who stood up to the villain Discord and saved Equestria from eternal chaos.", "root", "", "Princess Celestia", "", "-d /root -M -o -r -u 0"]
    config.vm.provision "shell", path: "scripts/post_system_user.sh", args: ["celestia"]
    config.vm.provision "shell", path: "scripts/post_celestia.sh"
    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["luna", "I am pleased with your offering! So pleased, I may eat it instead of eating you!", "root", "", "Princess Luna", "", "-k /dev/null -m -r"]
    config.vm.provision "shell", path: "scripts/post_system_user.sh", args: ["luna"]
    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["cadance", "Sunshine, sunshine, ladybugs awake! Clap your hooves and do a little shake!", "root", "", "Princess Cadance", "", "-k /dev/null -m -r"]
    config.vm.provision "shell", path: "scripts/post_system_user.sh", args: ["cadance"]
    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["twilight", "All the ponies in this town are crazy!", "users", "", "Princess Twilight Sparkle", "", "-k /dev/null -m -r"]
    config.vm.provision "shell", path: "scripts/post_system_user.sh", args: ["twilight"]
    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["spike", "Can you explode twice?", "users", "", "Spike", "", "-k /dev/null -m -r"]
    config.vm.provision "shell", path: "scripts/post_system_user.sh", args: ["spike"]
    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["pinkie", "It'll be as easy as pie.", "users", "", "Pinkie Pie", "", "-k /dev/null -m -r"]
    config.vm.provision "shell", path: "scripts/post_system_user.sh", args: ["pinkie"]
    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["applejack", "Soup's on, everypony!", "users", "", "Applejack", "", "-k /dev/null -m -r"]
    config.vm.provision "shell", path: "scripts/post_system_user.sh", args: ["applejack"]
    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["rainbow", "Hey, I could clear this sky in ten seconds flat.", "users", "", "Rainbow Dash", "", "-k /dev/null -m -r"]
    config.vm.provision "shell", path: "scripts/post_system_user.sh", args: ["rainbow"]
    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["rarity", "Take that, you ruffian!", "users", "", "Rarity", "", "-k /dev/null -m -r"]
    config.vm.provision "shell", path: "scripts/post_system_user.sh", args: ["rarity"]
    config.vm.provision "shell", path: "scripts/user_add.sh", args: ["fluttershy", "I'd like to be a tree.", "users", "", "Fluttershy", "", "-k /dev/null -m -r"]
    config.vm.provision "shell", path: "scripts/post_system_user.sh", args: ["fluttershy"]

    config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "/tmp/root/home/#{DEFAULT_USER}/.ssh/id_rsa"
    config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/tmp/root/home/#{DEFAULT_USER}/.ssh/id_rsa.pub"
    config.vm.provision "shell", path: "scripts/user_default.sh"

    config.vm.provision "file", source: "etc/sudoers", destination: "/tmp/root/etc/sudoers"
    config.vm.provision "shell", path: "scripts/end.sh"
end
