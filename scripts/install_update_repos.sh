#!/usr/bin/env bash
set -eu
source '/tmp/vagrant/common.sh'

log info "Refreshing zypper repositories"
sudo zypper --non-interactive refresh
