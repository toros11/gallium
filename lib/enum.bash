#!/bin/bash

enum_declare ()
{
    local name="${1}" ; shift
    local value_cnt=${#@}
    eval "${name}=($*)"

    for (( i=0; i < value_cnt ; i++ )) ; do
        s=$1 ; shift
        if bash --version | grep -q "4.[0-9]" ; then
            declare -rg "${s}=${i}"
        else
            eval "readonly ${s}=${i}"
        fi
    done
}

enum_list_from_until ()
{
    local from=${1} to="${2}" ; shift 2
    local vals=("${@}")
    local r=()

    for (( i=from ; i <= to ; i++ )) ; do
        r+=("${vals[i]}")
    done
    echo "${r[@]}"
}

enum_list_from ()
{
    local from="${1}" ; shift
    local vals=("${@}")

    enum_list_from_until "${from}" "$((${#vals[@]} - 1))" "${vals[@]}"
}
