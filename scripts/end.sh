#!/bin/bash -eu
source '/tmp/vagrant/common.sh'

log_info "Locking vagrant user..."
if [ "$(whoami)" == "vagrant" ]
then
    log_debug "Randomising password for vagrant..."
    echo "vagrant:$(uuidgen)" | sudo /usr/sbin/chpasswd
fi

log_debug "Cleaning up provisioned files..."
if [ -f /tmp/DEFAULT_USER ]
then 
    rm -f /tmp/DEFAULT_USER
fi
if [ -d /tmp/vagrant ]
then
    rm -rf /tmp/vagrant
fi

log_info "Updating sudoers..."
if [ -r /tmp/root/etc/sudoers ]
then
    migrate_file_root /tmp/root/etc/sudoers /etc/sudoers
    sudo rm -f /tmp/root/etc/sudoers
fi

if [ -d /tmp/root ]
then
    rm -rf /tmp/root
fi

if [ -d /home/vagrant/.ssh ]
then
    log_debug "Removing authorised keys for vagrant..."
    rm -r /home/vagrant/.ssh/
fi

if [ -f /tmp/vagrant-shell ]
then
    rm -f /tmp/vagrant-shell
fi
