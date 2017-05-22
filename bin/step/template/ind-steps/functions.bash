#!/bin/bash
. "${ORGCODEDIR}/external_libraries/functions/enum.bash"

enum_declare "STAGES" init install preconfigure boot postconfigure provide

# Overrides $starting_steps output to also show the information
# of the step/stage currenttly in process
if [[ "${DEBUG_MODE}" == "true" ]]; then
    default_set_title()
    {
        [ "$*" != "" ] && step_title="($stage, $step) $*"
    }
fi

get_build_state ()
{
    [[ -f ${LINKCODEDIR}/.state ]] || return $init
    # get stage from state file
    stage=$(cat ${LINKCODEDIR}/.state)
    # strip the stpe name (ouput is stage,step
    stage="${stage%,*}"
    # set stage its reference value
    stage=${!stage}
    # $(sudo kill -0 $(sudo cat ${LINKCODEDIR}.pid 2> /dev/null) 2> /dev/null) && stage=$postconfigure
    echo $stage
}

define_start_stage ()
{
    start_from=$init
    # if the first parameter is a numerical
    if [[ ${1} =~ ^[0-9]+$ ]]; then
        # make sure the value is part of the enum set
        if [[ -n ${!STAGES[${1}]} ]] ; then
            start_from=$1
        fi
        shift
    fi
    echo $start_from
}

#
# main functions
#

run_steps ()
{
    local step="${1}" stage="${2}"
    local step_include="${ORGCODEDIR}/ind-steps/step-${step}/include.bash"
    (
        [[ -f "${step_include}" ]] && . "${step_include}"
        . "${ORGCODEDIR}/ind-steps/step-${step}/${stage}.sh"
    )
}

VM_STATE=0
execute ()
{
    # by default the start stage is set to init, it can be changed by passing in a new stage as the
    # first argument when calling the function
    local start_stage=$(define_start_stage $1)
    local steps="${@}"
    # Set stages to start at $init or the provided stage
    local stages=($(enum_list_from $start_stage "${STAGES[@]}"))

    # each stage is executed for every step before moving on. this gives us flexibility when creating complex
    # clusters  where multiple applications works together and proper setup of applications depends on other
    # applications having a certain state/setup.
    for stage in ${stages[@]} ; do
        [[ $stage -ge $boot ]] && VM_STATE=1
        for step in ${steps[@]} ; do
            [[ -d "${ORGCODEDIR}/ind-steps/step-${step}" ]] || continue
            [[ -f "${ORGCODEDIR}/ind-steps/step-${step}/${stage}.sh" ]] && run_steps "${step}" "${stage}"
            case $? in
                200) # this return code is for intended exists, stop the loop and exit succedfully
                    exit 0 ;;
                255)
                    [[ $(get_build_state) -ge $boot ]] && shutdown || destroy
                    exit 255 ;;
            esac
            echo "${stage},${step}" > ${LINKCODEDIR}/.state
        done
    done
}

#
# cleanup
#

destroy ()
{
    # should call some destroy function
    return 0
}

shutdown ()
{
    # should call some kill function
    return 0
}
