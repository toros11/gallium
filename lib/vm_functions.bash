#!/bin/bash

vm_ssh ()
{
    : "${SSH_KEY:?"should be defined"}"
    : "${IP_ADDR:?"should be defined"}"

    local user="${VM_USER:-root}"
    local ssh_options=(
        "${ssh_options[@]:-
            "-o StrictHostKeyChecking=no"
            "-o LogLevel=quiet"
            "-o UserKnownHostsFile=/dev/null"}"
    )

    [[ -f "${SSH_KEY}" ]] || return 1

    $(type -P ssh) -i "${SSH_KEY}" $(for opt in "${ssh_options[@]}" ; do echo "${opt}" ; done) "${user}@${IP_ADDR}" "${@}"
}

vm_chroot ()
{
    : "${TMP_ROOT:?"should be defined"}"

    [[ -d "${TMP_ROOT}" ]] || return 1
    sudo $(type -P chroot) "${TMP_ROOT}" "${SHELL}" -c "${@}"
}

vm_install_package ()
{
    local pkg_mgr="${PKG_MGR:-yum}"
    local src="${PKG_SRC}" # used if we want to install package directly from url

    local pkg="${1}"
    (
        $starting_step "Install package ${pkg}"
        vm_run_cmd "rpm -q --quiet ${pkg}"
        $skip_step_if_already_done; set -ex
        if [[ -n "${src}" ]] ; then
            pkg="${src}"
        fi
        vm_run_cmd "${pkg_mgr} install -y ${pkg}"
    ) ; prev_cmd_failed
}

vm_wait_for ()
{
    local service="${step:-service}"
    local condition="${@}"
    local timeout="${timeout:-60}"
    local sleep_time="${sleep_time:-3}"
    local readonly start_time=$(date +%s)

    while :; do
        vm_run_cmd "${condition}" && return 0
        [[ $(( $(date +%s) - start_time )) -gt $timeout ]] && { echo "${service} ready" ; return 0 ; }
        echo "Waiting for ${service}..."
        sleep ${sleep_time}
    done

    echo "${service} timed out..."
    return 255
}

# Wrapper function for running commands on nodes so we don't have to make seprate
# scripts for performing the same commands before and after the image is running.
vm_run_cmd ()
{
    : "${VM_STATE:?"should be defined"}"
    local call_cmd

    case ${VM_STATE} in
        0 ) call_cmd="vm_chroot";;
        1 ) call_cmd="vm_ssh" ;;
    esac

    for cmd in "${@}" ; do
        ${call_cmd} "${cmd}"
    done
}

