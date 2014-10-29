#!/bin/bash -eu
source '/tmp/vagrant/common.sh'

log_info "Refreshing zypper repositories"
sudo zypper --non-interactive refresh
