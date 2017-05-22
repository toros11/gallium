#!/bin/bash
set -e
# From a list of passed arguments ($2) extract all arguments that are defined in a list of
# available arguments ($1) and specified in the format of --arg-name arg-value.
# Example of how a list would look
#  acceptable_arg_list="
#      arg1
#      arg2
#      arg3
#  "
#  Two special type of args are accepted
#  arg_name::flag. argument will be expanded as true/false value. (--all)
#  arg_name::enum. argument can be built as a list of elements. (--if0=<value0>, if1=<value1>)
#
# Once extracted enums can be used as an array, flags as boolean and by default as a normal variable.

define_arg_value ()
{
    local arg="${1}"
    
    if [[ ${!arg} == "flaggable" ]]; then
        # Flags have no value, they are set to true if they are included can be set immideatly
        echo "set_as_flag"
    elif [[ ${!arg} == "0" ]]; then
        # normal args get their dummy variable set to 0 and doesn't require any additional checks
        echo "${arg}"
    elif [[ -z ${!arg} ]]; then
        # enums have their dummys setup as e_<name><n> and needs different syntax in order to generate a usable array
        ( index="e_${arg%?}" ; [[ "${!index}" == "enumerable" ]] ) || {
            exit 1
        }
        argument_base="${arg%?}"
        argument_index="${arg: -1}"
        echo "${argument_base}[$argument_index]"
    fi
}

# Create a reference variable for each acceptable argument so we don't have to keep checking
# if an argument is supposed to be extractable.
create_reference_variable ()
{
    local value="${1}"

    if [[ "${value}" =~ "::flag" ]]; then
        read -r "${value%::*}" <<< "flaggable"
    elif [[ "${value}" =~ "::enum" ]]; then
        read -r "e_${value%::*}" <<< "enumerable"
    else
        read -r "${value}" <<< 0
    fi
}

delete_reference_variable ()
{
    local value="${1}"

    if [[ "${value}" =~ "::flag" ]]; then
        value="${value%::*}"
        if [[ ${!value} == "flaggable" ]]; then
            unset "${value}"
        fi
    elif [[ "${value}" =~ "::enum" ]]; then
        unset "e_${value%::*}"
    elif [[ ${!value} == "0" ]]; then
        unset "${value}"
    fi
}

reference_variables ()
{
    local method="${1}" ; shift
    local args=( ${@} )

    for value in "${args[@]}" ; do
        "${method}"_reference_variable "${value}" || exit 1
    done
}

extract_args ()
{
    local extractable_args=( ${1} ) ; shift
    local argument

    [[ -z ${1} ]] && return 0

    reference_variables create "${extractable_args[@]}"
    
    # Generate useable variables from arguments
    for value in "${@}" ; do
        if [[ -n "${argument}" ]] ; then
            # values should not start with a special character
            [[ "${value}" =~ ^[a-zA-Z0-9] ]] || { echo "Invalid value for ${argument}, ${value}" ; exit 1 ; }
            read -r "${argument}" <<< "${value}"
            unset argument value
        elif [[ "${value}" =~ ^"--"* ]]; then
            argument=$(define_arg_value "${value#*--}") || { echo "Invalid argument: ${value}" ; exit 1 ; }

            if [[ $argument == "set_as_flag" ]]; then
                read -r "${value#*--}" <<< true
                unset argument
            fi
        fi
    done

    reference_variables delete "${extractable_args[@]}"
}
