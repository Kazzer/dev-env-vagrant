#!/usr/bin/env bash
set -eu
source '/tmp/vagrant/common.sh'

log info "Updating zypper packages"
sudo zypper rr 1 2 3 4 5 6
sudo zypper ar -f -n 'Main Repository (OSS)' http://download.opensuse.org/tumbleweed/repo/oss/ download.opensuse.org-oss
sudo zypper ar -f -n 'Main Repository (NON-OSS)' http://download.opensuse.org/tumbleweed/repo/non-oss/ download.opensuse.org-non-oss
sudo zypper ar -f -n 'Main Update Repository' http://download.opensuse.org/update/tumbleweed/ download.opensuse.org-tumbleweed
sudo zypper --non-interactive --gpg-auto-import-keys dist-upgrade
