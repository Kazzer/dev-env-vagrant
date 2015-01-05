#!/bin/bash -eu
source '/tmp/vagrant/common.sh'

# project name
project="example"

# project owner
project_owner="example"

# project url (https or ssh)
project_url="git@github.com:${project_owner}/${project}.git"

# user to own the project
user="${default_user}"

# path to setup repository
path="/home/${user}/${project_owner}/${project}/"

# name for the remote
remote="origin"

if [ ! -d "${path}" ]
then
    log_info "Setting up ${project}"
    sudo -u "${user}" mkdir -p "${path}"

    log_debug "Checking for git access from host..."
    echo $(ssh -o StrictHostKeyChecking=no git@github.com) &>/dev/null

    mkdir -p "/tmp/${project_owner}/${project}/"
    pushd "/tmp/${project_owner}/${project}/" &>/dev/null
    git init
    if [ -z "$(git remote | grep "${remote}")" ]
    then
        git remote add "${remote}" "${project_url}"
    fi

    default_branch="$(git ls-remote --heads "${remote}" | grep "$(git ls-remote "${remote}" HEAD | cut -f1)" | grep -v HEAD | cut -f2)"
    default_branch="${default_branch##*/}"
    git fetch "${remote}" "${default_branch}"
    git checkout "${default_branch}"
    popd &>/dev/null

    sudo -u "${user}" cp -a --no-preserve=ownership "/tmp/${project_owner}/${project}/." "${path}"
fi
