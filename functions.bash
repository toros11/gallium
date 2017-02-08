#!/bin/bash

## General utility functions

abs_path="$( cd "$( dirname "$0" )" && pwd )"

bold ()
{
    local normal=$(tput sgr0) bold=$(tput bold)
    echo "${bold}${1}${normal}"
}

trim ()
{
    local string="${1}"
    string=$(sed 's/ *$//g' <<< "${string}")
    string=$(sed 's/^ *//g' <<< "${string}")

    echo "${string}"
}

require_environment ()
{
    [[ -f ${PWD}/.envfile ]] && { . .envfile ; } || {
        echo "[ERROR] No environment initialized."
        exit 0
    }
    : ${env_root_path}="?:Missing variable $root_path."
}


## From a list of passed arguments ($2) extract all arguments that are defined in a list of
## available arguments ($1) and specified in the format of --arg-name arg-value.
## Example of how a list would look
##  acceptable_arg_list="
##      arg1
##      arg2
##      arg3
##  "
##  Two special type of args are accepted
##  arg_name::flag. argument will be expanded as true/false value. (--all)
##  arg_name::enum. argument can be built as a list of elements. (--if0=<value0>, if1=<value1>)
##
## Once extracted enums can be used as an array, flags as boolean and by default as a normal variable.

extract_args ()
{
    local extractable_args=( ${1} ) ; shift

    [[ -z ${1} ]] && return 0

    # Create a dummy variable for each acceptable argument so we don't have to check more than once
    # if an argument is extractable.
    # Note: flag/enum type of arguments require specific value in order to "represent" a certain type.
    for value in "${extractable_args[@]}" ; do
        [[ "${value}" =~ "::flag" ]] && { new_value="${value%::*}" ; read -r "${new_value}" <<< "flaggable" ; continue ; }
        [[ "${value}" =~ "::enum" ]] && { new_value="${value%::*}" ; read -r "e_${new_value}" <<< "enumerable" ; continue ; }
        read -r "$value" <<< 0
    done

    for value in "${@}" ; do
        # TODO: Make sure proper parsing of arguments takes place, i.e. "--name --nic" / --name / -- -- /
        [[ -n "${argument}"              ]] && { read -r "${argument}" <<< "${value}" ; unset argument value ; continue ; }
        [[ "${value}" =~ ^"--"*          ]] && { argument="${value#*--}" ; }
        [[ -z ${!argument}               ]] && {
            ( arg="e_${argument%?}" ; [[ "${!arg}" == "enumerable" ]] ) || { echo "Invalid argument: ${value}" ; exit 1 ; }
            argument_base="${argument%?}"
            argument_index=${argument: -1}
            argument="${argument_base}[$argument_index]"
            continue
        }
        [[ ${!argument} == "flaggable"   ]] && { read -r "${argument}" <<< true ; unset argument value ; continue ; }
        argument="${argument}"

        # If the argument is of type that takes n entries make it into an array 
    done

    for value in "${extractable_args[@]}" ; do
        [[ "${value}" =~ "::flag" ]] && {
            value="${value%::*}"
            [[ ${!value} == "flaggable" ]] && unset $value
            continue
        }

        [[ "${value}" =~ "::enum" ]] && { unset "e_${value%::*}" ; continue ; }
        [[ ${!value} == "0" ]] && unset $value
    done
}


# TODO: write documentation
parse_conf()
{

    check_one_word () {
        [[ $(wc -w <<< "$1") -eq 1     ]] && { echo "Cannot contain spaces: $1" ; exit 1; }
        [[ "$1" =~ ^"{" || $1 =~ "}"$  ]] && { echo "Dangerous pattern: $1" ; exit 1; }
        [[ "$1" == *","* || $1 =~ "."$ ]] && { echo "Dangerous pattern: $1" ; exit 1; }
    }

    local file=${1} elemnt_id=0 cnt=0 element_name

    while read -r line ; do
        [[ ${line} =~ ^"#" ]] && continue

        [[ ${line} == *[\[\]]* ]] && {

            element_name=$(sed 's/.*\[\([^]]*\)\].*/\1/g' <<< "${line}")
            element_name=$(trim $element_name)
            element_id=( ${cnt} )
            (( cnt+= 1 ))
        } || {
            [[ $line ]] && {
                param_name="${line%=*}"
                param_value="${line#*=}"

                check_one_word "${element_name}"
                check_one_word "${param_name}"

                read -r "${element_name}_${param_name}[${element_id}]" <<< "${param_value}"
            }
        }
    done < ${file}
    read "${element_name}_count" <<< "${cnt}"
}

enum_declare ()
{
    local public_name=${1} ; shift
    local enum=(${@})

    for (( i=0; i < ${#enum[@]} ; i++ )) ; do
        eval "readonly ${enum[i]}=${i}"
    done
    
    eval "${public_name}=(\${@})"
}

enum_from ()
{
    local r=()
    local enum=($(eval "echo \${${1}[@]}")) ; shift

    for i in $(seq $1 ${#enum[@]}) ; do r+=( ${enum[i]} ) ; done
    echo "${r[@]}"
}

enum_to ()
{
    local r=()
    local enum=($(eval "echo \${${1}[@]}")) ; shift

    for i in $(seq 0 ${#enum[$1]}) ; do r+=( ${enum[i]} ) ; done
    echo "${r[@]}"
}
