#!/bin/bash

trim ()
{
    local string="${1}"
    string=$(sed 's/ *$//g' <<< "${string}")
    string=$(sed 's/^ *//g' <<< "${string}")

    echo "${string}"
}

check_one_word ()
{
    local passed=false

    if [[ $(wc -w <<< "$1") -gt 1 ]]; then
        echo "Cannot contain spaces: $1"
    elif [[ "$1" =~ ^"{" || $1 =~ "}"$  ]]; then
        echo "Dangerous pattern: $1"
    elif [[ "$1" == *","* || $1 =~ "."$ ]]; then
        echo "Dangerous pattern: $1"
    else
        passed=true
    fi

    $passed
}

create_value_index ()
{
    local element="$1" param="$2" idx="$3" value="$4"
    check_one_word "${param}"

    read -r "${element}_${param}[${idx}]" <<< "${value}"
}

parse_conf_element ()
{
    local file="${1}" element_name="${2}" cnt=0 skip=false

    : "${element_name:?"provide the name of the elements to parse"}"
    check_one_word "${element_name}"

    if [[ ! -f ${1} ]]; then
        echo "Error file not found $file"
        exit 1
    fi

    while read -r line ; do
        [[ ${line} =~ ^"#" ]] && continue
        if [[ ${line} == *[\[\]]* ]]; then
            if [[ "$(trim "$(sed 's/.*\[\([^]]*\)\].*/\1/g' <<< "${line}")")" != "${element_name}" ]]; then
                skip=true
            else
                skip=false
                (( cnt++ ))
                continue
            fi
        fi

        $skip && continue
        [[ -n $line ]] && create_value_index "${element_name}" "${line%=*}" $(( cnt -1 )) "${line#*=}"
    done < "${file}"

    read -r "${element_name}_count" <<< "${cnt}"
}


# This function had bugs when there are types of different names
# replaced parse_conf_element ()
#
# {
#     local file="${1}" elemnt_id=0 cnt=0 element_name=${2}

#     while read -r line ; do
#         [[ ${line} =~ ^"#" ]] && continue

#         if [[ ${line} == *[\[\]]* ]]; then
#             element_name=$(trim $(sed 's/.*\[\([^]]*\)\].*/\1/g' <<< "${line}"))
#             element_name=$(trim $element_name)
#             check_one_word "${element_name}"
#             (( cnt++ ))
#         else
#             [[ -n $line ]] && create_value_index "${element_name}" "${line%=*}" $(( cnt -1 )) "${line#*=}"
#         fi
#     done < "${file}"

#     read "${element_name}_count" <<< "${cnt}"
# }
