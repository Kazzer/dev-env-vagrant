#!/usr/bin/env bash
set -eu
source '/tmp/vagrant/common.sh'

group="${1}"

log info "Adding group ${group}"
sudo /usr/sbin/groupadd -f "${group}"
