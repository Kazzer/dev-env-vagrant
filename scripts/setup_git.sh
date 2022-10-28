#!/bin/bash -eu
source '/tmp/vagrant/common.sh'

# project owner
project_owner="${1}"

# project name
project="${2}"

# project url (https or ssh)
project_url="git@github.com:${project_owner}/${project}.git"

# user to own the project
user="${default_user}"

# path to setup repository
path="/home/${user}/${project_owner}/"

log debug "Checking for git access from host..."
echo $(ssh -o StrictHostKeyChecking=no git@github.com) &>/dev/null

if [ ! -d "${path}" ]
then
    mkdir -p "${path}"
    pushd "${path}" &>/dev/null
        sudo -u "${user}" git init
    popd &>/dev/null
fi

pushd "${path}" &>/dev/null
    if ( ! git remote show "${project}" &>/dev/null)
    then
        sudo -u "${user}" git remote add "${project}" "${project_url}"
    fi

    default_branch="$(cut -f2 <(grep -v HEAD <(grep "$(cut -f1 <(git ls-remote "${project}" HEAD))" <(git ls-remote --heads "${project}"))))"
    default_branch="${default_branch#refs/heads/}"
    sudo -u "${user}" git fetch "${project}" "${default_branch}"

    if [ "$(wc -l < <(git branch --list "${project}"))" -eq 0 ]
    then
        sudo -u "${user}" git checkout --orphan "${project}"
    else
        sudo -u "${user}" git checkout "${project}"
    fi

    sudo -u "${user}" git reset --hard "${project}/${default_branch}"
    sudo -u "${user}" git branch --set-upstream-to="${project}/${default_branch}"
popd &>/dev/null
