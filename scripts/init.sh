#!/bin/bash -eu
source '/tmp/vagrant/common.sh'

log_info "Setting MOTD..."
if [ -r /tmp/root/etc/motd ]
then
    log_debug "    Set MOTD to $(cat /tmp/root/etc/motd)"
    migrate_file_root /tmp/root/etc/motd /etc/motd
fi

log_info "Setting Hostname..."
if [ -r /tmp/root/etc/HOSTNAME ]
then
    log_debug "    Set Hostname to $(cat /tmp/root/etc/HOSTNAME)"
    sed_root /etc/hosts 's/\(127.0.0.2	\).*/\1'"$(cat /tmp/root/etc/HOSTNAME) $(cat /tmp/root/etc/HOSTNAME | cut -d. -f1)"'/g'
    migrate_file_root /tmp/root/etc/HOSTNAME /etc/HOSTNAME
fi

log_info "Configuring /etc/skel..."
if [ -d /tmp/root/etc/skel ]
then
    for skel_file in $(find /tmp/root/etc/skel -type f)
    do
        log_debug "    Creating ${skel_file:9}..."
        create_file_root "${skel_file}" "${skel_file:9}"
    done
fi

log_info "Configuring /etc/init.d..."
if [ -d /tmp/root/etc/init.d ]
then
    for initd_file in $(find /tmp/root/etc/init.d -type f)
    do
        log_debug "    Creating ${initd_file:9}..."
        create_file_root "${initd_file}" "${initd_file:9}"
        sudo /sbin/insserv "$(basename "${initd_file}")"
    done
fi

log_info "Locking root user..."
sudo /usr/sbin/usermod -s /sbin/nologin -L root
