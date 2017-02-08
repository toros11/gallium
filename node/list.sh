#!/bin/bash

. ${root_path}/functions.bash
. ${abs_path}/functions.bash
require_environment

extractable_args="
    pretty::flag
"


simple_usage()
{
    printf "  %s\t\t%s\n" "list" "Lists all nodes"
}

usage ()
{
cat <<EOF

This command lists all the nodes. The following parameters can be used:

  options:

    --pretty                            Formatted output, including information about the node.

EOF
}

[[ "${1}" == "--help"       ]] && { usage ; exit ; }
[[ "${1}" == "simple_usage" ]] && { simple_usage ; exit ; }

nodes=$(ls -d ${env_root_path}/nodes/*/ 2>/dev/null | sed "s,$env_root_path\/nodes,,g" | sed 's,/,,g')
args=( "${@}" )
extract_args "${extractable_args}" "${args[@]}"

[[ $? == 1 ]] || {
    [[ ${pretty} == "true" ]] && pretty_output || {
            for node in ${nodes[@]} ; do
                printf " %s\n" "${node}"
            done
        }
}
    
