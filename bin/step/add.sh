#!/bin/bash

# this operation should probably be removed or replaced with import
# which would include a set of base steps that are commonly included on one more nodes
# in a cluster environment

. ${root_path}/../functions.bash
require_environment

simple_usage()
{
    printf "  %s\t\t%s\n" "add" "Adds a step"
}

[[ "${1}" == "--help" || -z "${1}" ]] && { usage ; exit ; }
[[ "${1}" == "simple_usage"        ]] && { simple_usage ; exit ; }
