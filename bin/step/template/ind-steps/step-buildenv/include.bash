#1/bin/bash

enum_declare "CLEANUP" node_stage host_stage all

cleanup ()
{
    local cleanup_type="${1}"
    local build_stagae="${2:-0}"
    local cleanup_cmd

    if [[ "${build_stage}" -gt "${boot}" ]]; then
        cleanup_cmd="kill"
    elif [[ "${build_stage}" -lt "${boot}" ]]; then
        cleanup_cmd="destroy"
    fi

    case "${cleanup_type}" in
        $node_state)
            # Cleanup all the nodes
            for node in ${NODES[@]} ; do
                (
                    $starting_group "${cleanup_cmd} ${node%,*}"
                    false
                    $skip_group_if_unnecessary
                    "${ORGCODEDIR}/nodes/${node}/${cleanup_cmd}.sh"
                ) ; prev_cmd_failed
            done ;;
        # Steps that reverse the settings that was setup on the machine
        # which the environment was build on
        $host_stage) ;;

        # Cleans up both 
        $all)
            cleanup $node_stage $build_stage
            cleanup $host_stage $build_stage ;;
    esac
}

