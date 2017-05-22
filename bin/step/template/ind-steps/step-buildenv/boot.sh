#!/bin/bash

(
    node_build_pid=()
    for node in ${NODES[@]} ; do
        $starting_group "Environment: building ${node}"
        false
        $skip_group_if_unnecessary
        for node in ${NODES[@]} ; do
            if which bootstraper 2> /dev/null ; then
                boostraper env build --node "${node}" &> "${ORGCODEDIR}/nodes/${node}/build.log" &
            else
                "${ORGCODEDIR}/nodes/${node}/build.sh" &> "${ORGCODEDIR}/nodes/${node}/build.log" &
            fi
        done
        node_build_pid[$!]="${node}"
    done

    for procc in "${!node_build_pid[@]}" ; do
        echo "Waiting for ${node_build_pid[procc]}.."
        wait $procc
    done
) ; prev_cmd_failed

