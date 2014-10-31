#!/bin/bash -eu
source '/tmp/vagrant/common.sh'

log_info "Locking vagrant user..."
log_debug "Randomising password for vagrant..."
echo "vagrant:$(uuidgen)" | sudo /usr/sbin/chpasswd

log_info "Updating sudoers..."
if [ -r /tmp/root/etc/sudoers ]
then
    migrate_file_root /tmp/root/etc/sudoers /etc/sudoers
fi

log_debug "Removing authorised keys for vagrant..."
rm -r /home/vagrant/.ssh/
