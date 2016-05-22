#!/bin/bash -eu
source '/tmp/vagrant/common.sh'

# package name for zypper
package="${1}"

# command for the installer (eg. zypper install, pip install, gem install)
installer=(rpm -ivh --includedocs)

# list of conflicting packages (space-separated inside parentheses)
eval "conflicts=(${3:-})"

# list of dependecies that aren't automatically resolved (space-separated inside parentheses)
# you can specify a specific installer for the dependency using the format 'package:installer'
eval "dependencies=(${2:-})"

log info "Installing ${package}"

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
    fi
done

if [ -f "/tmp/${package}" ]
then
    if ( rpm -V -p "/tmp/${package}" | grep missing &>/dev/null )
    then
        log debug "Installing ${package}..."
        sudo "${installer[@]}" "${package}"
    fi
    sudo rm -f "/tmp/${package}"
fi
