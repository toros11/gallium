# #!/bin/bash

. ${root_path}/functions.bash

extractable_args="
    node
    environment::flag
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

    --environment                         Build the environment

EOF
}


[[ "${1}" == "--help" || -z $1 ]] && { usage ; exit ; }
[[ "${1}" == "simple_usage"    ]] && { simple_usage ; exit ; }

require_environment
args=( "${@}" )
extract_args "${extractable_args}" "${args[@]}"

[[ -n $node ]] && {  ${env_root_path}/nodes/${node}/build.sh ; exit 0 ; }
[[ ${environment} == "true" ]] && ${env_root_path}/build.sh
