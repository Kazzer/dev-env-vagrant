#!/bin/bash -eu
v=1
default_user="developer"

function log_info {
    if [ ${v} -ge 1 ]
    then
        echo "$*"
    fi
}

function log_debug {
    if [ ${v} -ge 2 ]
    then
        echo "$*"
    fi
}

function migrate_file_root {
    local source_file=$1
    local destination=$2
    sudo chown "$(stat -c "%U:%G" "${destination}")" "${source_file}"
    sudo chmod "$(stat -c "%a" "${destination}")" "${source_file}"
    sudo mv "${source_file}" "${destination}"
}

function create_file_root {
    local source_file=$1
    local destination=$2
    sudo mkdir -p "$(dirname "${destination}")"
    sudo cp "${source_file}" "${destination}"
}

function sed_root {
    local source_file=$1
    local pattern=$2
    sudo sed -i "${pattern}" "${source_file}"
}

function create_file_user {
    local user=$1
    local source_file=$2
    local destination=$3
    sudo -u "${user}" mkdir -p "$(dirname "${destination}")"
    sudo -u "${user}" cp "${source_file}" "${destination}"
}
