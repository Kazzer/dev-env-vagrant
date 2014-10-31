#!/usr/bin/env bash
set -eu
source '/tmp/vagrant/common.sh'

log debug "Locking out root user since celestia is root now..."
sudo /usr/sbin/usermod -s /sbin/nologin -L root
