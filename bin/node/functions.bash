#!/bin/bash

render_cfg ()
{
    cat <<EOF >> "${env_root_path}/nodes/${name:-1}/datadir.conf"
idx=\${1:-0}

# include global config
. \${ORGCODEDIR}/datadir.conf

# include utility
# .\${ORGCODEDIR}/external_libraries/functions/vm_functions.sh
# .\${ORGCODEDIR}/external_libraries/functions/loopback_mount.bash "raw/qcow2"
# .\${ORGCODEDIR}/external_libraries/functions/qemu_builder.bash "user_mode/tap"

level="node"

# vm specs

name=${name:-1}
cpu_type=${cpu_type}
mem_size=${mem_size:-512}
cpu_num=${cpu_num:-1}
vnc_addr=${vnc_add:-127.0.0.1}
vnc_port=${vnc_port}
serial=${serial}
EOF
}

render_vif_cfg ()
{
    local node="${1}" ; shift
    local interface_params="${@}"

    (
        eval "${interface_params//,/ }"
        mkdir -p "${env_root_path}/nodes/${node}/guestroot/etc/sysconfig/network-scripts"
        [[ -f "${env_root_path}/nodes/${node}/guestroot/etc/sysconfig/network-scripts/ifcfg-${tap}" ]] &&  {
            echo "Failed: duplicate nic name, ifcfg-${tap}."
            confirm_delete=false
            delete_node "${node}"
            exit 1
        }
        cat <<EOF >> "${env_root_path}/nodes/${node}/guestroot/etc/sysconfig/network-scripts/ifcfg-${tap}"
DEVICE=${tap}
ONBOOT=yes
NW_CONTROLLED=no
TYPE=${type}
IPADDR=${ip}
NETMASK=255.255.255.0
EOF

        echo "nics+=( name=tap_${tap} hwaddr=${mac} bridge=${bridge} )" >> "${env_root_path}/nodes/${node}/datadir.conf"
    )
}

render_network ()
{
    local node="${1}" hostname="${2}"

    mkdir -p "${env_root_path}/nodes/${node}/guestroot/etc/sysconfig"
    cat <<EOF > "${env_root_path}/nodes/${node}/guestroot/etc/sysconfig/network"
NETWORKING=yes
HOSTNAME=${hostname}
EOF
    if [[ -n "${gw}" ]] ; then
        echo "GATEWAY=${gw}" >> "${env_root_path}/nodes/${node}/guestroot/etc/sysconfig/network"
    fi
}

generate_symlinks ()
{
    local node_path="${1}"

    (
        cd ${node_path}
        
        for file in $(ls ${env_root_path}) ; do
            if [[ "${file#*.}" == "sh" ]] ; then
                ln -s "../../${file}" "${node_path}/${file}"
            fi
        done
    )
}


create_node ()
{
    local template="${1}" node_name=${2}  build=${3:-true}
    local node_path="${env_root_path}/nodes/$node_name"

    [[ -d "${env_root_path}/nodes" ]] || "mkdir -p ${env_root_path}/nodes"
    [[ -d "${node_path}"       ]] && { echo "[ERROR] Node already exists." ; exit 1 ; }

    output="Creating node: $(bold ${node_name})"

    if [[ -n $template ]] ; then
        if [[ -d ${node_path%/*}/${template} ]] ; then
            cp -a "${node_path%/*}/${template}" "${node_path}"
            output="${output}, copy from $(bold ${template})"
        elif [[ -d ${abs_path}/template/${template} ]] ; then
            cp -a "${abs_path}/template/${template}" "${node_path}"
            generate_symlinks ${node_path}
            output="${output}, template from $(bold ${template})"
        else
            echo "[ERROR] Invalid node template."
            exit 252
        fi
    else 
        mkdir -p "${node_path}"
        touch ${node_path}/datadir.conf
        touch ${node_path}/steplist.conf

        generate_symlinks ${node_path}
    fi

    printf "\n%s\n\n" "${output}"
}

confirm_command ()
{
    local action="${1}" target="${2}"

    while true; do
        read -p "Are you sure you wish to ${action} ${target}? y/[n]: " yn
        case $yn in
            [Yy]* )
                return 0 ;;
            [Nn]* )
                return 1 ;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

delete_node ()
{
    local node_name="${1}"
    local node_path="${env_root_path}/nodes/${node_name}"

    [[ -d "${node_path}" ]] || { echo "[ERROR] Invalid node_name: $node_name." ; exit ; }

    $confirm_delete && {
        confirm_pass=$(confirm_command "delete" $node_name)
        $confirm_pass || { printf "\n%s\n\n" "*** Delete: $(bold $node_name), aborted." ; return $? ; }
    }

    printf "\n%s\n\n" "*** Removing node: $(bold ${node_name})."
    rm -rf "${node_path}"

    return $?
}

delete_all ()
{
    local nodes=$(cd "${env_root_path}/nodes/" ; ls -d */ 2> /dev/null | sed 's/\///g')

    [[ -n $nodes ]] || { echo "[ERROR] No nodes to delete" ; exit 1 ; }
    $(confirm_command "delete" "all nodes") || { printf "\n%s\n\n" "*** Delete: $(bold $node_name), aborted." ; exit $? ; }

    printf "%s\n" ""
    for node in $nodes ; do
        printf "%s\n" "*** Removing node: $(bold ${node})."
        rm -rf "${env_root_path}/nodes/${node}"
    done
    printf "%s\n" ""
}  

new_node_id ()
{
    local counter=1000

    while [[ -d "$env_root_path/nodes/node-$counter" ]] ; do
        (( counter++ ))
    done
    echo "node-$counter"
}
