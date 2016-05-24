#!/usr/bin/env bash
set -eu
source '/tmp/vagrant/common.sh'

log warning "All: ${*}"

for arg in "${@}"
do
    log warning "Arg: ${arg}"
done
