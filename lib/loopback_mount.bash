#!/bin/bash
format="${1:-raw}"

if [[ ${format} == "raw" ]] ; then
    # include mount-partition
    if [[ ! -d ${BASH_SOURCE[0]%/*}/../mount-partition ]] ; then 
       git clone https://github.com/triggers/mount-partition.git ${BASH_SOURCE[0]%/*}/../mount-partition
    fi
    . "${BASH_SOURCE[0]%/*}/../mount-partition/mount-partition.sh" "load"
fi

mount_img ()
{
    : "${TMP_ROOT:?"should be defined"}"
    : "${VM_IMAGE:?"should be defined"}"

    case ${format} in
        raw) mount-partition --sudo "${VM_IMAGE}" 1 "${TMP_ROOT}" ;;
        qcow2)
            sudo qemu-nbd -c /dev/nbd0 ${VM_IMAGE}
            sudo mount "/dev/nbd0p2" ${TMP_ROOT}
            ;;
    esac
}

umount_img () 
{
    case ${format} in
        raw) umount-partition --sudo "${TMP_ROOT}" ;;
        qcow2) 
            sudo umount ${TMP_ROOT}
            sudo qemu-nbd -d /dev/nbd0
            ;;
    esac
}
