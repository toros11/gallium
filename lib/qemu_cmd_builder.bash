#!/bin/bash

networking="${1:-tap}"
: "${nics:?"should be defined"}"

if [[ "${networking}" == "user_mode" ]] ; then
    : "${ACCESS_PORT:?"should be defined"}"
fi

build_hostfwd_param()
{
    local ret_val="hostfwd=tcp::${ACCESS_PORT}-:22"

    if [[ -n "${extra_port_forward[@]}" ]] ; then
        for port in ${extra_port_forward[@]} ; do
            ret_val="${ret_val},hostfwd=tcp::$(( port + 10000 + idx ))-:${port}"
        done
    fi
    echo "${ret_val}"
}

build_nic_param()
{
    case "${networking}" in
        user_mode)
            hostfwd="$(build_hostfwd_param)"
            echo "-net nic,vlan=0,macaddr=${mac_addr},model=virtio,addr=$(( 3 + idx )) -net user,vlan=0,${hostfwd}" ;;
            tap)
                for (( i=0 ; i < ${#nics[@]} ; i++ )); do
                    nic=(${nics[i]})
                    echo "-netdev tap,ifname=${nic[0]#*=},script=,downscript=,id=${vm_name}${idx} -device virtio-net-pci,netdev=${vm_name}${idx},mac=${nic[1]#*=},bus=pci.0,addr=0x$((3 + ${idx}))"
                done ;;
    esac
}

exec_qemu_cmd()
{
    : "${VM_IMAGE:?"should be defined"}"
    local
    qemu-system-x86_64 \
        -machine accel=kvm \
        -cpu ${cpu_type} \
        -m ${mem_size} \
        -smp ${cpu_num} \
        -vnc ${vnc_addr}:${vnc_port} \
        -serial ${serial} \
        -serial pty \
        -drive file=${VM_IMAGE},media=disk,if=virtio,format=${format:-raw} \
        $(build_nic_param) \
        -daemonize \
        -pidfile ${LINKCODEDIR}/${vm_name}.pid
}
