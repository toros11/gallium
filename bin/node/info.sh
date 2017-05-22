#!/bin/bash

. ${root_path}/../functions.bash

include "extract_args"
include "${abs_path}/functions.bash"

require_environment

extractable_args="
    name
"

simple_usage()
{
    printf "  %s\t\t%s\n" "info" "Shows info about a node"
}

usage ()
{
cat <<EOF

This command lists information about a node. The following parameters can be used:

  options:

    --name                              name of the node.

EOF
}

[[ "${1}" == "--help" || -z "${1}" ]] && { usage ; exit ; }
[[ "${1}" == "simple_usage" ]] && { simple_usage ; exit ; }

args=( "${@}" )
extract_args "${extractable_args}" "${args[@]}"

[[ $? == 1 ]] || {
    echo "${name}"
}
    

