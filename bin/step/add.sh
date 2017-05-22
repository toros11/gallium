#!/bin/bash

. ${root_path}/../functions.bash
require_environment

simple_usage()
{
    printf "  %s\t\t%s\n" "add" "Adds a step"
}

[[ "${1}" == "--help" || -z "${1}" ]] && { usage ; exit ; }
[[ "${1}" == "simple_usage"        ]] && { simple_usage ; exit ; }
