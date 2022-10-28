#!/bin/bash -eu
source '/tmp/vagrant/common.sh'

# package name for zypper
package="${1}"

# target directory
target="${2}"

# command for the installer (eg. zypper install, pip install, gem install)
installer=(tar -xzvf)

# list of conflicting packages (space-separated inside parentheses)
eval "conflicts=(${4:-})"

# list of dependecies that aren't automatically resolved (space-separated inside parentheses)
# you can specify a specific installer for the dependency using the format 'package:installer'
eval "dependencies=(${3:-})"

log info "Installing ${package}"

if [ -f "/tmp/${package}" ]
then
    for conflict in "${conflicts[@]:+${conflicts[@]}}"
    do
        if [ "$(zypper --non-interactive search --match-exact -i -t package "${conflict}" | tail -1)" != "No matching items found." ]
        then
            log debug "Removing conflicting package ${conflict}..."
            sudo zypper --non-interactive remove "${conflict}"
        fi
    done

    for dependency in "${dependencies[@]:+${dependencies[@]}}"
    do
        dep_package=(${dependency/:/ })
        dep_installer=(${dep_package[@]:1})

        if [ "$(zypper --non-interactive search --match-exact -i -t package "${dep_package}" | tail -1)" == "No matching items found." ]
        then
            log debug "Installing dependency package ${dep_package}..."
            sudo "${dep_installer[@]:-${installer[@]}}" "${dep_package}"
            if [ -f "${dep_package}" ]
            then
                sudo rm -f "${dep_package}"
            fi
        fi
    done

    log debug "Installing ${package}..."
    sudo mkdir -p "${target}"
    sudo "${installer[@]}" "/tmp/${package}" -C "${target}"
    sudo rm -f "/tmp/${package}"
fi
