#!/bin/bash
. "${ORGCODEDIR}/external_libraries/functions/utility.bash"

enum_declare "STAGES" init install preconfigure boot postconfigure provide

get_env_state () {
    local stage=${1}

    # $(sudo [ -f "${CACHE_DIR}/${BRANCH}/${vm_name}.qcow2" ]) && stage=$boot
    # $(sudo kill -0 $(sudo cat ${NODE_DIR}/${vm_name}.pid 2> /dev/null) 2> /dev/null) && stage=$postconfigure

    echo $stage
}

define_stages () {
    local start_stage=${1}

    [[ $start_stage -gt 0 ]] || start_stage=$(get_env_state $start_stage)
    echo $(enum_from STAGES $start_stage)
}

run_steps ()
{
    local step="${1}" stage="${2}"
    local step_include="${ORGCODEDIR}/ind-steps/step-${step}/include.bash"
    echo "*** @step: ${step} - @stage: ${stage}"

    [[ -f "${step_include}" ]] && . "${step_include}"
    . "${ORGCODEDIR}/ind-steps/step-${step}/${stage}.sh"
}

execute ()
{
    local steps="${@}"
    local custom_start=${!STAGES[${start_stage}]}

    # If the vm is running it means at leat the boot phase has passed, and we
    # can skip the stages before that, it however does not mean that the environment
    # and its services are fully running so we still need stage postconfiguer/provide.
    local stages=($(define_stages $custom_start))
    
    # We first run init.sh for every step after which we run install.sh for every
    # step and so on. This is because some stages will need to happen before booting
    # the VM while others need to happen after boot.
    for stage in ${stages[@]} ; do
        for step in ${steps[@]} ; do
            echo "${stage},${step}" > ${LINKCODEDIR}/.state
            [[ -d "${ORGCODEDIR}/ind-steps/step-${step}" ]] || continue
            [[ -f "${ORGCODEDIR}/ind-steps/step-${step}/${stage}.sh" ]] && run_steps "${step}" "${stage}"
            case $? in
                200) return 0 ;;
                255) . "${ORGCODEDIR}/ind-steps/step-buildenv/common.bash"
                     [[ -n "${NODE_DIR}" ]] && { teardown_environment $(get_env_state $stage) ; exit 255 ; }
                     [[ -z "${NODE_DIR}" ]] && { teardown_host_settings ; exit 255 ; } ;;
            esac
        done
    done

    echo "running" > ${LINKCODEDIR}/.state
}

internal_ssh ()
{
    local user="${1:-root}"
    local ip_addr="${IP_ADDR:-2}"
    local ssh_key="${SSH_KEY}"

    [[ -f "${ssh_key}" ]] || return 1
    
    $(type -P ssh) -i "${ssh_key}" -o 'StrictHostKeyChecking=no' -o 'LogLevel=quiet' -o 'UserKnownHostsFile /dev/null' "${user}@${ip_addr}" "${@}"
}

internal_chroot ()
{
    [[ -d "${TMP_ROOT}" ]] || return 1    
    $(type -P chroot) "${TMP_ROOT}" "${SHELL}" -c "${@}"
}

internal_run ()
{
    return
}

teardown_environment () {
    "${ORGCODEDIR}/cleanup_env.sh"
}

teardown_host_settings () {
    "${ORGCODEDIR}/kill.sh"
}
