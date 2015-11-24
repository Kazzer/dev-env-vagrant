#!/usr/bin/env bash
set -eu
source '/tmp/vagrant/common.sh'

log info "Setting MOTD..."
if [ -r /tmp/root/etc/motd ]
then
    log debug "Set MOTD to $(cat /tmp/root/etc/motd)"
    migrate_file_root /tmp/root/etc/motd /etc/motd
    sudo rm -f /tmp/root/etc/motd
fi

log info "Configuring /etc/skel..."
if [ -d /tmp/root/etc/skel ]
then
    for skel_file in $(find /tmp/root/etc/skel -type f)
    do
        log debug "Creating ${skel_file:9}..."
        create_file_root "${skel_file}" "${skel_file:9}"
    done
    sudo rm -rf /tmp/root/etc/skel
fi

log info "Configuring /etc/init.d..."
if [ -d /tmp/root/etc/init.d ]
then
    for initd_file in $(find /tmp/root/etc/init.d -type f)
    do
        log debug "Creating ${initd_file:9}..."
        create_file_root "${initd_file}" "${initd_file:9}"
        sudo /sbin/insserv "${initd_file##*/}"
    done
    sudo rm -rf /tmp/root/etc/init.d
fi

log info "Locking root user..."
sudo /usr/sbin/usermod -s /sbin/nologin -L root
