#!/usr/bin/env bash
set -eu
source '/tmp/vagrant/common.sh'

# user name
user="${default_user}"
password="$(uuidgen)"

user_full_name="${user^}"

# primary group
primary_group="users"

# default shell
shell="/bin/bash"

if [ ! "$(id "${user}" 2>/dev/null)" ]
then
    log info "Configuring user ${user}"
    sudo /usr/sbin/useradd -c "${user_full_name}" -g "${primary_group}" -m -N -s "${shell}" "${user}"

    log debug "Creating user files..."
    if [ -d "/tmp/root/home/${user}" ]
    then
        sudo chown -R "${user}:$(id -gn "${user}")" "/tmp/root/home/${user}"
        for user_file in $(find "/tmp/root/home/${user}" -type f)
        do
            log debug "Creating ${user_file:9}..."
            create_file_user "${user}" "${user_file}" "${user_file:9}"
        done
        sudo rm -rf "/tmp/root/home/${user}"
    fi

    if [ -d "/home/${user}/.ssh/" ]
    then
        log debug "Configuring authorized_keys..."
        sudo -u "${user}" chmod 0700 "/home/${user}/.ssh/"
        if [ -f "/home/${user}/.ssh/id_rsa.pub" ]
        then
            sudo -u "${user}" cp "/home/${user}/.ssh/id_rsa.pub" "/home/${user}/.ssh/authorized_keys"
        fi
        if [ -f "/home/${user}/.ssh/authorized_keys" ]
        then
            sudo -u "${user}" chmod 0600 "/home/${user}/.ssh/authorized_keys"
        fi
    fi

    log debug "Setting password for ${user}..."
    echo "${user}:${password}" | sudo /usr/sbin/chpasswd
fi
