#!/usr/bin/env bash
set -eu
source '/tmp/vagrant/common.sh'

log info "Updating zypper packages"
sudo zypper --non-interactive update
