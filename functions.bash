#!/bin/bash

## General utility functions

abs_path="$( cd "$( dirname "$0" )" && pwd )"

bold ()
{
    local normal=$(tput sgr0) bold=$(tput bold)
    echo "${bold}${1}${normal}"
}

# recursively look for the .envfile
require_environment ()
{
    folder="${1:-${PWD}}"

    if [[ "${folder}" == "/" ]] ; then
        echo "[ERROR] No environment initialized."
        exit 0
    fi

    if [[ -f "${folder}/.envfile" ]] ; then
        . "${folder}/.envfile"
        : ${env_root_path}="?:Missing variable $root_path."
        exit 0
    fi
    require_environment "$(dirname ${folder})"
}

include ()
{
    local lib
    # The argument is an actual file
    if [[ -f "${1}" ]]; then
        lib="${1}"
    else
        lib="${root_path}/../lib/${1}.bash"
        if [[ ! -f "${lib}" ]]; then
            echo "Downloading ${lib}..."
            # mkdir -p ${env_root_path}/lib
            # curl -o ${env_root_path}/lib/${1} -OL "path/to/raw/file/on/github/"            
        fi
    fi
    . "${lib}" || echo "[ERROR]: Unable to source ${lib}, check that the file exists and there is no errors"
}
