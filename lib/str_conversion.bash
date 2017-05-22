#!/bin/bash

split_str ()
{
    local str="${1}" delimiter="${2}"
    local str_as_array=()

    until [[ -z "${str}" ]] ; do
        value="${str%%$delimiter*}"
        str_as_array+=( "${value}" )
        if [[ "${str}" == *"${delimiter}"* ]]; then
            str="${str/$value$delimiter/}"
        else
            str="${str/$value/}"
        fi
    done

    echo "${str_as_array[@]}"
}
