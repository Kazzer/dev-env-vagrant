#!/usr/bin/env bash
set -eu
declare -A LOG_LEVELS=([CRITICAL]=50 [ERROR]=40 [WARNING]=30 [INFO]=20 [DEBUG]=10)
verbosity="${LOG_LEVELS[INFO]}"
default_user="$(cat /tmp/DEFAULT_USER)"

function log {
    local level="${1}"
    local message="${*:2}"
    if [ "${LOG_LEVELS[${level^^}]:-0}" -ge "${verbosity}" ]
    then
        echo "[${level^^}] ${message}"
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
    sudo mkdir -p "${destination%/*}"
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
    sudo -u "${user}" mkdir -p "${destination%/*}"
    if [ ! -f "${destination}" ]
    then
        sudo -u "${user}" cp "${source_file}" "${destination}"
    else
        sudo -u "${user}" cat "${source_file}" >>"${destination}"
    fi
}

for (( i=1; i<=${#}; i++ ))
do
    case "${!i}" in
        --debug)
            verbosity="${LOG_LEVELS[DEBUG]}"
            set -- "${@:1:$i-1}" "${@:$i+1}"
            i=$((i - 1))
        ;;
        --quiet)
            verbosity="${LOG_LEVELS[WARNING]}"
            set -- "${@:1:$i-1}" "${@:$i+1}"
            i=$((i - 1))
        ;;
    esac
done
