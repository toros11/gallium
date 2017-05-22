#!/bin/bash

. ${root_path}/../functions.bash
include "extract_args"

extractable_args="
    node
    all::flag
"

simple_usage ()
{
    printf "  %s\t\t%s\n" "build" "Builds the complete enviroment or specified node/s"     
}

usage ()
{
cat <<EOF

This command deletes a node, the following parameters can be sent as aruments,

  options:

    --node                                Name of the node

    --all                                 Build the environment

EOF
}


[[ "${1}" == "--help" || -z $1 ]] && { usage ; exit ; }
[[ "${1}" == "simple_usage"    ]] && { simple_usage ; exit ; }

require_environment
args=( "${@}" )
extract_args "${extractable_args}" "${args[@]}"

if [[ ${all} == "true" ]]; then
    ${env_root_path}/build.sh
else
    [[ -n $node ]] && {  ${env_root_path}/nodes/${node}/build.sh ; exit 0 ; }
fi

