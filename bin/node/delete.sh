#!/bin/bash

. ${root_path}/../functions.bash

include "extract_args"
include "${abs_path}/functions.bash"

require_environment

confirm_delete=false
extractable_args="
    name
    all::flag
"

simple_usage ()
{
    printf "  %s\t%s\n" "delete" "Deletes a node"
}

usage ()
{
cat <<EOF

This command deletes a node, the following parameters can be sent as aruments,

  options:

    --name                              Name of the node

    --all                               Removes all nodes

EOF
}

[[ "${1}" == "--help" || -z $1 ]] && { usage ; exit ; }
[[ "${1}" == "simple_usage"    ]] && { simple_usage ; exit ; }


args=( "${@}" )
extract_args "${extractable_args}" "${args[@]}"
[[ $? == 1 ]] || {
    [[ ${all} == "true" ]] && delete_all || delete_node "${name}"
}
