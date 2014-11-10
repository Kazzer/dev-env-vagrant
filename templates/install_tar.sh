#!/bin/bash -eu
source '/tmp/vagrant/common.sh'

# human readable name for the package
name="Example"

# file name for tar
package="example-package.tar.gz"

# target directory
target="/opt/example-package/"

# command for the installer (eg. zypper install, pip install, gem install)
installer=(tar -xzvf)

# list of conflicting packages (space-separated inside parentheses)
conflicts=()

# list of dependecies that aren't automatically resolved (space-separated inside parentheses)
# you can specify a specific installer for the dependency using the format 'package:installer'
dependencies=()

log_info "Installing ${name}"

if [ ${#conflicts[@]} -gt 0 ]
then
    for conflict in "${conflicts[@]}"
    do
        if [ "$(zypper --non-interactive search --match-exact -i -t package "${conflict}" | tail -1)" != "No packages found." ]
        then
            log_debug "Removing conflicting package ${conflict}..."
            sudo zypper --non-interactive remove "${conflict}"
        fi
    done
fi

if [ ${#dependencies[@]} -gt 0 ]
then
    for dependency in "${dependencies[@]}"
    do
        dep_package=(${dependency/:/ })
        dep_installer=(${dep_package[@]:1})

        if [ "$(zypper --non-interactive search --match-exact -i -t package "${dep_package}" | tail -1)" == "No packages found." ]
        then
            log_debug "Installing dependency package ${dep_package}..."
            sudo "${dep_installer[@]:-${installer[@]}}" "${dep_package}"
        fi
    done
fi

if [ -f "/tmp/${package}" ]
then
    log_debug "Installing ${package}..."
    sudo mkdir -p "${target}"
    sudo "${installer[@]}" "/tmp/${package}" -C "${target}"
fi
