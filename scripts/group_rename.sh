#!/usr/bin/env bash
set -eu
source '/tmp/vagrant/common.sh'

original_group="${1}"
new_group="${2}"

log info "Renaming group ${original_group} to ${new_group}"
sudo /usr/sbin/groupmod -n "${new_group}" "${original_group}"
